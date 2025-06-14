import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/painting.dart';

import '../models/game_record.dart';
import '../models/game_record_form.dart';
import '../models/stadium.dart';
import '../models/team.dart';

class RecordService {
  static const String _fileName = 'game_records.json';

  // 싱글톤 패턴 구현
  static final RecordService _instance = RecordService._internal();

  factory RecordService() {
    return _instance;
  }

  RecordService._internal();

  /// 모든 경기 기록 가져오기
  Future<List<GameRecord>> getAllRecords() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => GameRecord.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // 새 기록 추가
  Future<GameRecord> addRecord(GameRecordForm form) async {
    final records = await getAllRecords();

    // 새 ID 생성 (가장 큰 ID + 1)
    final newId =
        records.isEmpty
            ? 1
            : records.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;

    // 이미지 파일 복사 (영구 저장)
    String? permanentImagePath;
    if (form.imagePath != null) {
      permanentImagePath = await _saveImagePermanently(form.imagePath!, newId);
    }

    // 새 기록 생성
    final newRecord = GameRecord(
      id: newId,
      dateTime: form.gameDateTime!,
      stadium: Stadium(id: 'temp', name: form.stadium!, city: ''),
      homeTeam: Team(
        id: 'home',
        name: form.homeTeam!,
        shortName: form.homeTeam!,
        primaryColor: Color(0xFF000000),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      awayTeam: Team(
        id: 'away',
        name: form.awayTeam!,
        shortName: form.awayTeam!,
        primaryColor: Color(0xFF000000),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      homeScore: form.homeScore ?? 0,
      awayScore: form.awayScore ?? 0,
      result: GameResult.win,
      isFavorite: false,
      imageUrl: permanentImagePath,
      seatInfo: form.seatInfo ?? '',
      memo: form.comment ?? '',
    );

    // 기록 목록에 추가
    records.add(newRecord);

    // 파일에 저장
    await _saveRecords(records);

    return newRecord;
  }

  // 기록 업데이트
  Future<GameRecord> updateRecord(int id, GameRecordForm form) async {
    final records = await getAllRecords();
    final index = records.indexWhere((record) => record.id == id);

    if (index == -1) {
      throw Exception('Record not found');
    }

    // 이미지 처리
    String? imageUrl = records[index].imageUrl;
    if (form.imagePath != null && !form.imagePath!.startsWith('assets/')) {
      // 새 이미지가 선택된 경우
      imageUrl = await _saveImagePermanently(form.imagePath!, id);
    }

    // 업데이트된 기록 생성
    final updatedRecord = GameRecord(
      id: id,
      dateTime: form.gameDateTime!,
      stadium: Stadium(id: 'temp', name: form.stadium!, city: ''),
      homeTeam: Team(
        id: 'home',
        name: form.homeTeam!,
        shortName: form.homeTeam!,
        primaryColor: Color(0xFF000000),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      awayTeam: Team(
        id: 'away',
        name: form.awayTeam!,
        shortName: form.awayTeam!,
        primaryColor: Color(0xFF000000),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      homeScore: form.homeScore ?? 0,
      awayScore: form.awayScore ?? 0,
      result: GameResult.win,
      isFavorite: records[index].isFavorite,
      imageUrl: imageUrl,
      seatInfo: form.seatInfo ?? '',
      memo: form.comment ?? '',
    );

    // 기존 기록 업데이트
    records[index] = updatedRecord;

    // 파일에 저장
    await _saveRecords(records);

    return updatedRecord;
  }

  // 기록 삭제
  Future<void> deleteRecord(int id) async {
    final records = await getAllRecords();
    final index = records.indexWhere((record) => record.id == id);

    if (index == -1) {
      return;
    }

    // 이미지 파일 삭제
    final record = records[index];
    if (record.imageUrl != null && !record.imageUrl!.startsWith('assets/')) {
      final imageFile = File(record.imageUrl!);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }

    // 기록 삭제
    records.removeAt(index);

    // 파일에 저장
    await _saveRecords(records);
  }

  // 즐겨찾기 토글
  Future<GameRecord> toggleFavorite(int id) async {
    final records = await getAllRecords();
    final index = records.indexWhere((record) => record.id == id);

    if (index == -1) {
      throw Exception('Record not found');
    }

    // 즐겨찾기 상태 토글
    final updatedRecord = records[index].copyWith(
      isFavorite: !records[index].isFavorite,
    );

    // 기록 업데이트
    records[index] = updatedRecord;

    // 파일에 저장
    await _saveRecords(records);

    return updatedRecord;
  }

  // 로컬 파일 경로 가져오기
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  // 기록 목록 저장
  Future<void> _saveRecords(List<GameRecord> records) async {
    final file = await _getLocalFile();
    final jsonList = records.map((record) => record.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  // 이미지 영구 저장
  Future<String> _saveImagePermanently(String sourcePath, int recordId) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/record_images');

    // 이미지 디렉토리 생성
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // 파일 확장자 추출
    final extension = sourcePath.split('.').last;

    // 새 파일 경로
    final newPath = '${imagesDir.path}/record_$recordId.$extension';

    // 파일 복사
    final sourceFile = File(sourcePath);
    await sourceFile.copy(newPath);

    return newPath;
  }
}

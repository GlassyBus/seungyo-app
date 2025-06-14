import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../database/database.dart';
import '../models/game_record.dart';
import '../models/game_record_form.dart';
import '../services/database_service.dart';

class RecordService {
  // 싱글톤 패턴 구현
  static final RecordService _instance = RecordService._internal();

  factory RecordService() => _instance;

  RecordService._internal();

  AppDatabase get _database => DatabaseService().database;

  // GameRecord 형태로 모든 기록 가져오기
  Future<List<GameRecord>> getAllRecords() async {
    try {
      final dbRecords = await _database.getAllRecords();
      final gameRecords = <GameRecord>[];

      for (final record in dbRecords) {
        final gameRecord = await DatabaseService().convertRecordToGameRecord(record);
        if (gameRecord != null) {
          gameRecords.add(gameRecord);
        }
      }

      return gameRecords;
    } catch (e) {
      print('Error loading records: $e');
      return [];
    }
  }

  // Database 형태로 모든 기록 가져오기
  Future<List<Record>> getAllDatabaseRecords() async {
    try {
      return await _database.getAllRecords();
    } catch (e) {
      print('Error loading database records: $e');
      return [];
    }
  }

  // 즐겨찾기 기록만 가져오기
  Future<List<Record>> getFavoriteRecords() async {
    try {
      return await _database.getFavoriteRecords();
    } catch (e) {
      print('Error loading favorite records: $e');
      return [];
    }
  }

  // 특정 날짜의 기록 가져오기
  Future<List<Record>> getRecordsByDate(DateTime date) async {
    try {
      return await _database.getRecordsByDate(date);
    } catch (e) {
      print('Error loading records by date: $e');
      return [];
    }
  }

  // 특정 팀의 기록 가져오기
  Future<List<Record>> getRecordsByTeam(String teamId) async {
    try {
      return await _database.getRecordsByTeam(teamId);
    } catch (e) {
      print('Error loading records by team: $e');
      return [];
    }
  }

  // 새 기록 추가
  Future<int> addRecord(GameRecordForm form) async {
    try {
      // 필수 필드 검증
      if (!form.isValid) {
        throw Exception('필수 정보가 누락되었습니다.');
      }

      // 이미지 파일 처리
      List<String> photosPaths = [];
      if (form.imagePath != null) {
        final permanentPath = await _saveImagePermanently(form.imagePath!);
        photosPaths.add(permanentPath);
      }

      // 새 기록 생성
      final recordId = await _database.insertRecord(
        RecordsCompanion.insert(
          date: form.gameDateTime!,
          stadiumId: form.stadiumId!,
          homeTeamId: form.homeTeamId!,
          awayTeamId: form.awayTeamId!,
          homeScore: form.homeScore ?? 0,
          awayScore: form.awayScore ?? 0,
          canceled: Value(form.canceled),
          seat: Value(form.seatInfo),
          comment: Value(form.comment),
          photosJson: Value(photosPaths.isNotEmpty ? jsonEncode(photosPaths) : null),
          isFavorite: Value(form.isFavorite),
        ),
      );

      return recordId;
    } catch (e) {
      print('Error adding record: $e');
      rethrow;
    }
  }

  // 기록 업데이트
  Future<bool> updateRecord(int id, GameRecordForm form) async {
    try {
      final existingRecord = await _getRecordById(id);
      if (existingRecord == null) {
        throw Exception('Record not found');
      }

      // 이미지 처리
      List<String> photosPaths = [];
      if (existingRecord.photosJson != null) {
        photosPaths = List<String>.from(jsonDecode(existingRecord.photosJson!));
      }

      if (form.imagePath != null && !form.imagePath!.startsWith('/data/')) {
        // 새 이미지가 선택된 경우
        final permanentPath = await _saveImagePermanently(form.imagePath!);
        photosPaths.add(permanentPath);
      }

      // 업데이트된 기록 생성
      final updatedRecord = RecordsCompanion(
        id: Value(id),
        date: Value(form.gameDateTime!),
        stadiumId: Value(form.stadiumId ?? existingRecord.stadiumId),
        homeTeamId: Value(form.homeTeamId ?? existingRecord.homeTeamId),
        awayTeamId: Value(form.awayTeamId ?? existingRecord.awayTeamId),
        homeScore: Value(form.homeScore ?? 0),
        awayScore: Value(form.awayScore ?? 0),
        canceled: Value(existingRecord.canceled),
        seat: Value(form.seatInfo),
        comment: Value(form.comment),
        photosJson: Value(photosPaths.isNotEmpty ? jsonEncode(photosPaths) : null),
        isFavorite: Value(existingRecord.isFavorite),
        createdAt: Value(existingRecord.createdAt),
      );

      return await _database.updateRecord(updatedRecord);
    } catch (e) {
      print('Error updating record: $e');
      return false;
    }
  }

  // 기록 삭제
  Future<bool> deleteRecord(int id) async {
    try {
      final record = await _getRecordById(id);
      if (record == null) return false;

      // 관련 이미지 파일 삭제
      if (record.photosJson != null) {
        final photosPaths = List<String>.from(jsonDecode(record.photosJson!));
        for (final path in photosPaths) {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      // 기록 삭제
      final deletedCount = await _database.deleteRecord(id);
      return deletedCount > 0;
    } catch (e) {
      print('Error deleting record: $e');
      return false;
    }
  }

  // 즐겨찾기 토글
  Future<bool> toggleFavorite(int id) async {
    try {
      final record = await _getRecordById(id);
      if (record == null) return false;

      final updatedRecord = RecordsCompanion(
        id: Value(id),
        date: Value(record.date),
        stadiumId: Value(record.stadiumId),
        homeTeamId: Value(record.homeTeamId),
        awayTeamId: Value(record.awayTeamId),
        homeScore: Value(record.homeScore),
        awayScore: Value(record.awayScore),
        canceled: Value(record.canceled),
        seat: Value(record.seat),
        comment: Value(record.comment),
        photosJson: Value(record.photosJson),
        isFavorite: Value(!record.isFavorite),
        createdAt: Value(record.createdAt),
      );

      return await _database.updateRecord(updatedRecord);
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // 통계 관련 메서드
  Future<Map<String, int>> getStats(String myTeamId) async {
    try {
      final winCount = await _database.getWinCount(myTeamId);
      final loseCount = await _database.getLoseCount(myTeamId);
      final totalCount = await _database.getTotalGameCount(myTeamId);

      return {'win': winCount, 'lose': loseCount, 'total': totalCount};
    } catch (e) {
      print('Error getting stats: $e');
      return {'win': 0, 'lose': 0, 'total': 0};
    }
  }

  // ID로 기록 조회 (내부 메서드)
  Future<Record?> _getRecordById(int id) async {
    final records = await _database.getAllRecords();
    try {
      return records.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // 이미지 영구 저장
  Future<String> _saveImagePermanently(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/record_images');

    // 이미지 디렉토리 생성
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // 파일 확장자 추출
    final extension = sourcePath.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 새 파일 경로
    final newPath = '${imagesDir.path}/record_${timestamp}.$extension';

    // 파일 복사
    final sourceFile = File(sourcePath);
    await sourceFile.copy(newPath);

    return newPath;
  }
}

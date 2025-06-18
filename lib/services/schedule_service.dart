import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/game_schedule.dart';
import '../services/record_service.dart';
import '../constants/team_data.dart';

class ScheduleService {
  static const String _fileName = 'game_schedules.json';

  // 싱글톤 패턴 구현
  static final ScheduleService _instance = ScheduleService._internal();

  factory ScheduleService() {
    return _instance;
  }

  ScheduleService._internal();

  // 모든 경기 일정 가져오기
  Future<List<GameSchedule>> getAllSchedules() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        // 파일이 없으면 샘플 데이터 생성 후 저장
        final sampleData = _generateSampleData();
        await _saveSchedules(sampleData);
        return sampleData;
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => GameSchedule.fromJson(json)).toList();
    } catch (e) {
      print('Error loading schedules: $e');
      return _generateSampleData();
    }
  }

  // 특정 월의 경기 일정 가져오기
  Future<List<GameSchedule>> getSchedulesByMonth(int year, int month) async {
    try {
      final allSchedules = await getAllSchedules();
      return allSchedules
          .where((schedule) => schedule.dateTime.year == year && schedule.dateTime.month == month)
          .toList();
    } catch (e) {
      print('Error getting schedules by month: $e');
      return [];
    }
  }

  // 특정 날짜의 경기 일정 가져오기
  Future<List<GameSchedule>> getSchedulesByDate(DateTime date) async {
    try {
      final allSchedules = await getAllSchedules();
      return allSchedules
          .where(
            (schedule) =>
                schedule.dateTime.year == date.year &&
                schedule.dateTime.month == date.month &&
                schedule.dateTime.day == date.day,
          )
          .toList();
    } catch (e) {
      print('Error getting schedules by date: $e');
      return [];
    }
  }

  // 직관 기록과 경기 일정 연동
  Future<void> syncWithRecords() async {
    try {
      final recordService = RecordService();
      final records = await recordService.getAllRecords();
      final schedules = await getAllSchedules();

      bool hasChanges = false;

      for (int i = 0; i < schedules.length; i++) {
        final schedule = schedules[i];

        // 같은 날짜, 같은 팀의 경기 찾기
        final matchingRecords =
            records.where((record) {
              return record.gameDate.year == schedule.dateTime.year &&
                  record.gameDate.month == schedule.dateTime.month &&
                  record.gameDate.day == schedule.dateTime.day &&
                  ((record.homeTeam.name == schedule.homeTeam && record.awayTeam.name == schedule.awayTeam) ||
                      (record.homeTeam.name == schedule.awayTeam && record.awayTeam.name == schedule.homeTeam));
            }).toList();

        if (matchingRecords.isNotEmpty) {
          final matchingRecord = matchingRecords.first;
          schedules[i] = schedule.copyWith(
            hasAttended: true,
            attendedRecordId: matchingRecord.id,
            homeScore: matchingRecord.homeScore,
            awayScore: matchingRecord.awayScore,
            status: GameStatus.finished,
          );
          hasChanges = true;
        }
      }

      if (hasChanges) {
        await _saveSchedules(schedules);
      }
    } catch (e) {
      print('Error syncing with records: $e');
    }
  }

  // 경기 일정 저장
  Future<void> _saveSchedules(List<GameSchedule> schedules) async {
    try {
      final file = await _getLocalFile();
      final jsonList = schedules.map((schedule) => schedule.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving schedules: $e');
    }
  }

  // 로컬 파일 경로 가져오기
  Future<File> _getLocalFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return File('${directory.path}/$_fileName');
    } catch (e) {
      print('Error getting local file: $e');
      rethrow;
    }
  }

  // 샘플 데이터 생성
  List<GameSchedule> _generateSampleData() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // 팀 데이터에서 로고 가져오기
    String getTeamLogo(String teamName) {
      final team = TeamData.teams.firstWhere(
        (t) => t.name.contains(teamName) || t.code == teamName,
        orElse: () => TeamData.teams.first,
      );
      return team.emblem;
    }

    return [
      // 이번 달 5일 경기
      GameSchedule(
        id: 1,
        dateTime: DateTime(year, month, 5, 14, 0),
        stadium: '고척',
        homeTeam: 'SSG',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.finished,
        homeScore: 3,
        awayScore: 2,
      ),

      // 이번 달 15일 경기 (패배)
      GameSchedule(
        id: 2,
        dateTime: DateTime(year, month, 15, 14, 0),
        stadium: '고척',
        homeTeam: 'SSG',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.finished,
        homeScore: 0,
        awayScore: 1,
      ),

      // 이번 달 16일 경기 (승리)
      GameSchedule(
        id: 3,
        dateTime: DateTime(year, month, 16, 14, 0),
        stadium: '고척',
        homeTeam: 'SSG',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.finished,
        homeScore: 5,
        awayScore: 2,
      ),

      // 이번 달 17일 경기 (승리)
      GameSchedule(
        id: 4,
        dateTime: DateTime(year, month, 17, 14, 0),
        stadium: '고척',
        homeTeam: 'SSG',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.finished,
        homeScore: 1,
        awayScore: 0,
      ),
      GameSchedule(
        id: 5,
        dateTime: DateTime(year, month, 17, 17, 0),
        stadium: '잠실',
        homeTeam: 'LG',
        awayTeam: 'KIA',
        homeTeamLogo: getTeamLogo('LG'),
        awayTeamLogo: getTeamLogo('KIA'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 6,
        dateTime: DateTime(year, month, 17, 18, 30),
        stadium: '잠실',
        homeTeam: '한화',
        awayTeam: '삼성',
        homeTeamLogo: getTeamLogo('한화'),
        awayTeamLogo: getTeamLogo('삼성'),
        status: GameStatus.scheduled,
      ),

      // 이번 달 18일 경기 (무승부)
      GameSchedule(
        id: 7,
        dateTime: DateTime(year, month, 18, 14, 0),
        stadium: '고척',
        homeTeam: 'SSG',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.finished,
        homeScore: 1,
        awayScore: 1,
      ),

      // 이번 달 19일 경기 (우천 취소)
      GameSchedule(
        id: 8,
        dateTime: DateTime(year, month, 19, 14, 0),
        stadium: '고척',
        homeTeam: 'SSG',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.canceled,
      ),

      // 오늘 경기 (진행 예정)
      GameSchedule(
        id: 9,
        dateTime: DateTime(year, month, now.day, 18, 30),
        stadium: '문학',
        homeTeam: 'SK',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('SSG'),
        // SK가 없어서 SSG로 대체
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.scheduled,
      ),
    ];
  }
}

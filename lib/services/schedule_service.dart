import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

import '../constants/team_data.dart';
import '../models/game_schedule.dart';
import '../services/record_service.dart';

/// 경기 일정 관리 서비스
class ScheduleService {
  static const String _fileName = 'game_schedules.json';
  static const String _baseUrl = 'https://www.koreabaseball.com';

  // 싱글톤 패턴 구현
  static final ScheduleService _instance = ScheduleService._internal();

  factory ScheduleService() => _instance;

  ScheduleService._internal();

  /// 팀 로고 가져오기
  String getTeamLogo(String teamName) {
    // 팀 이름 매핑을 더 정확하게 처리
    final nameMapping = {
      '두산': 'bears',
      '키움': 'heroes',
      'SSG': 'landers',
      'LG': 'twins',
      '삼성': 'lions',
      '한화': 'eagles',
      'NC': 'dinos',
      '롯데': 'giants',
      'KIA': 'tigers',
      'KT': 'wiz',
    };

    final teamId = nameMapping[teamName];
    if (teamId != null) {
      final team = TeamData.getById(teamId);
      if (team != null) {
        return team.emblem;
      }
    }

    // 직접 코드로 찾기
    final team = TeamData.getByCode(teamName);
    if (team != null) {
      return team.emblem;
    }

    // 이름으로 찾기 (부분 매칭)
    final foundTeam = TeamData.teams.firstWhere(
      (t) => t.name.contains(teamName) || teamName.contains(t.code),
      orElse: () => TeamData.teams.first,
    );

    return foundTeam.emblem;
  }

  /// 모든 경기 일정 가져오기
  Future<List<GameSchedule>> getAllSchedules() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        // 파일이 없으면 현재 달 샘플 데이터 생성 후 저장
        final sampleData = _generateCurrentMonthSampleData();
        await _saveSchedules(sampleData);
        return sampleData;
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => GameSchedule.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 경기 일정 로드 실패: $e');
      }
      // 에러 발생 시 현재 달 샘플 데이터 반환
      return _generateCurrentMonthSampleData();
    }
  }

  /// 실제 KBO API에서 특정 월의 경기 일정 가져오기
  Future<List<GameSchedule>> getSchedulesByMonth(int year, int month) async {
    try {
      if (kDebugMode) {
        print('🔄 ${year}년 ${month}월 경기 일정 가져오는 중...');
      }

      // 현재는 샘플 데이터를 사용하되, 요청한 월에 맞춰 생성
      final schedules = _generateSampleDataForMonth(year, month);

      if (kDebugMode) {
        print('✅ ${schedules.length}개 경기 일정 로드 성공');
      }

      // 로컬에 캐시 저장
      await _saveSchedulesToCache(schedules);
      return schedules;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 경기 일정 가져오기 실패: $e');
      }
      // 에러 발생 시 로컬 캐시 또는 샘플 데이터 반환
      return await _getSchedulesFromCache(year, month);
    }
  }

  /// KBO 공식 API에서 데이터 가져오기 (현재는 비활성화)
  Future<List<GameSchedule>> _fetchFromKBOAPI(int year, int month) async {
    // KBO API 호출은 현재 비활성화하고 샘플 데이터 사용
    return [];
  }

  /// KBO API 응답 파싱 (현재는 비활성화)
  List<GameSchedule> _parseKBOResponse(Map<String, dynamic> jsonData) {
    return [];
  }

  /// 개별 경기 일정 파싱 (현재는 비활성화)
  GameSchedule? _parseGameSchedule(Map<String, dynamic> data) {
    return null;
  }

  /// 날짜 시간 파싱
  DateTime? _parseDateTime(String dateStr, String timeStr) {
    try {
      // 날짜 형식: 20250125
      if (dateStr.length != 8) return null;

      final year = int.parse(dateStr.substring(0, 4));
      final month = int.parse(dateStr.substring(4, 6));
      final day = int.parse(dateStr.substring(6, 8));

      // 시간 형식: 18:30
      final timeParts = timeStr.split(':');
      final hour = timeParts.isNotEmpty ? int.parse(timeParts[0]) : 18;
      final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 30;

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  /// 팀 이름 정규화
  String _normalizeTeamName(String teamName) {
    final teamMap = {
      'LG': 'LG',
      'KT': 'KT',
      'SSG': 'SSG',
      '키움': '키움',
      'KIA': 'KIA',
      '롯데': '롯데',
      '두산': '두산',
      'NC': 'NC',
      '삼성': '삼성',
      '한화': '한화',
    };

    return teamMap[teamName] ?? teamName;
  }

  /// 경기 상태 파싱
  GameStatus _parseGameStatus(String? statusCode) {
    switch (statusCode) {
      case '1': // 경기 예정
        return GameStatus.scheduled;
      case '2': // 경기 중
        return GameStatus.inProgress;
      case '3': // 경기 종료
        return GameStatus.finished;
      case '4': // 경기 취소
        return GameStatus.canceled;
      case '5': // 경기 연기
        return GameStatus.postponed;
      default:
        return GameStatus.scheduled;
    }
  }

  /// 로컬 캐시에서 경기 일정 가져오기
  Future<List<GameSchedule>> _getSchedulesFromCache(int year, int month) async {
    try {
      final allSchedules = await getAllSchedules();
      return allSchedules
          .where(
            (schedule) =>
                schedule.dateTime.year == year &&
                schedule.dateTime.month == month,
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 캐시에서 경기 일정 가져오기 실패: $e');
      }
      // 최후의 수단으로 샘플 데이터 반환
      return _generateSampleDataForMonth(year, month);
    }
  }

  /// 현재 달 샘플 데이터 생성
  List<GameSchedule> _generateCurrentMonthSampleData() {
    final now = DateTime.now();
    return _generateSampleDataForMonth(now.year, now.month);
  }

  /// 특정 월의 샘플 데이터 생성
  List<GameSchedule> _generateSampleDataForMonth(int year, int month) {
    final schedules = <GameSchedule>[];
    final now = DateTime.now();

    // 해당 월의 첫 날과 마지막 날 계산
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    // 팀 리스트
    final teams = [
      '두산',
      'LG',
      'SSG',
      '키움',
      'KIA',
      '롯데',
      'NC',
      '삼성',
      '한화',
      'KT',
    ];
    final stadiums = ['잠실', '고척', '문학', '사직', '대구', '광주', '창원', '대전', '수원'];

    int gameId = 1;

    // 매일 2-3경기씩 생성 (주말에는 더 많이)
    for (int day = 1; day <= lastDay.day; day++) {
      final gameDate = DateTime(year, month, day);
      final isWeekend =
          gameDate.weekday == DateTime.saturday ||
          gameDate.weekday == DateTime.sunday;
      final gamesPerDay = isWeekend ? 5 : 3; // 주말에는 5경기, 평일에는 3경기

      for (int gameIndex = 0; gameIndex < gamesPerDay; gameIndex++) {
        // 팀 매칭 (중복 방지)
        final homeTeamIndex = (gameIndex * 2) % teams.length;
        final awayTeamIndex = (gameIndex * 2 + 1) % teams.length;
        final homeTeam = teams[homeTeamIndex];
        final awayTeam = teams[awayTeamIndex];

        // 경기 시간 설정
        final gameTime =
            gameIndex == 0 && isWeekend
                ? DateTime(year, month, day, 14, 0) // 주말 첫 경기는 14:00
                : DateTime(year, month, day, 18, 30); // 나머지는 18:30

        // 경기 상태 결정
        GameStatus status;
        int? homeScore;
        int? awayScore;

        if (gameTime.isBefore(now)) {
          // 과거 경기는 종료
          status = GameStatus.finished;
          homeScore = (gameIndex * 3 + day) % 10;
          awayScore = (gameIndex * 2 + day) % 8;
        } else if (gameTime.day == now.day &&
            gameTime.month == now.month &&
            gameTime.year == now.year) {
          // 오늘 경기는 예정 또는 진행 중
          status =
              gameTime.hour < now.hour
                  ? GameStatus.inProgress
                  : GameStatus.scheduled;
        } else {
          // 미래 경기는 예정
          status = GameStatus.scheduled;
        }

        schedules.add(
          GameSchedule(
            id: gameId++,
            dateTime: gameTime,
            stadium: stadiums[gameIndex % stadiums.length],
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            homeTeamLogo: getTeamLogo(homeTeam),
            awayTeamLogo: getTeamLogo(awayTeam),
            status: status,
            homeScore: homeScore,
            awayScore: awayScore,
          ),
        );
      }
    }

    return schedules;
  }

  /// 캐시에 경기 일정 저장
  Future<void> _saveSchedulesToCache(List<GameSchedule> schedules) async {
    try {
      // 기존 캐시와 병합
      final existingSchedules = await getAllSchedules();
      final allSchedules = <GameSchedule>[...existingSchedules];

      // 새로운 데이터로 업데이트
      for (final newSchedule in schedules) {
        final existingIndex = allSchedules.indexWhere(
          (existing) => existing.id == newSchedule.id,
        );

        if (existingIndex >= 0) {
          allSchedules[existingIndex] = newSchedule;
        } else {
          allSchedules.add(newSchedule);
        }
      }

      await _saveSchedules(allSchedules);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 캐시 저장 실패: $e');
      }
    }
  }

  /// 특정 날짜의 경기 일정 가져오기 (기존 메서드 이름 유지)
  Future<List<GameSchedule>> getSchedulesByDate(DateTime date) async {
    try {
      if (kDebugMode) {
        print(
          'ScheduleService: Getting schedules for ${date.year}-${date.month}-${date.day}',
        );
      }
      final allSchedules = await getAllSchedules();
      if (kDebugMode) {
        print(
          'ScheduleService: Total schedules loaded: ${allSchedules.length}',
        );
      }

      final filteredSchedules =
          allSchedules
              .where(
                (schedule) =>
                    schedule.dateTime.year == date.year &&
                    schedule.dateTime.month == date.month &&
                    schedule.dateTime.day == date.day,
              )
              .toList();

      if (kDebugMode) {
        print(
          'ScheduleService: Found ${filteredSchedules.length} schedules for ${date.year}-${date.month}-${date.day}',
        );
        for (final schedule in filteredSchedules) {
          print(
            'ScheduleService: - ${schedule.homeTeam} vs ${schedule.awayTeam} at ${schedule.stadium}',
          );
        }
      }

      return filteredSchedules;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 특정 날짜 경기 일정 가져오기 실패: $e');
      }
      return [];
    }
  }

  /// 특정 날짜의 경기 일정 가져오기 (NotificationService 호환성을 위한 별칭)
  Future<List<GameSchedule>> getSchedulesForDate(DateTime date) async {
    return getSchedulesByDate(date);
  }

  /// 앞으로 예정된 경기 일정 가져오기
  Future<List<GameSchedule>> getUpcomingSchedules() async {
    try {
      final allSchedules = await getAllSchedules();
      final now = DateTime.now();

      return allSchedules.where((schedule) {
        return schedule.dateTime.isAfter(now) &&
            schedule.status == GameStatus.scheduled;
      }).toList();
    } catch (error) {
      if (kDebugMode) {
        print('❌ 예정된 경기 일정 가져오기 실패: $error');
      }
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
                  ((record.homeTeam.name == schedule.homeTeam &&
                          record.awayTeam.name == schedule.awayTeam) ||
                      (record.homeTeam.name == schedule.awayTeam &&
                          record.awayTeam.name == schedule.homeTeam));
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
    // 팀 데이터에서 로고 가져오기
    String getTeamLogo(String teamName) {
      // 팀 이름 매핑을 더 정확하게 처리
      final nameMapping = {
        '두산': 'bears',
        '키움': 'heroes',
        'SSG': 'landers',
        'LG': 'twins',
        '삼성': 'lions',
        '한화': 'eagles',
        'NC': 'dinos',
        '롯데': 'giants',
        'KIA': 'tigers',
        'KT': 'wiz',
      };

      final teamId = nameMapping[teamName];
      if (teamId != null) {
        final team = TeamData.getById(teamId);
        if (team != null) {
          return team.emblem;
        }
      }

      // 직접 코드로 찾기
      final team = TeamData.getByCode(teamName);
      if (team != null) {
        return team.emblem;
      }

      // 이름으로 찾기 (부분 매칭)
      final foundTeam = TeamData.teams.firstWhere(
        (t) => t.name.contains(teamName) || teamName.contains(t.code),
        orElse: () => TeamData.teams.first,
      );

      return foundTeam.emblem;
    }

    return [
      GameSchedule(
        id: 1,
        dateTime: DateTime(2025, 6, 1, 14, 0),
        stadium: '고척',
        homeTeam: '두산',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('두산'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.finished,
        homeScore: 0,
        awayScore: 1,
      ),
      GameSchedule(
        id: 2,
        dateTime: DateTime(2025, 6, 1, 17, 0),
        stadium: '잠실',
        homeTeam: '삼성',
        awayTeam: 'LG',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('LG'),
        status: GameStatus.finished,
        homeScore: 6,
        awayScore: 4,
      ),
      GameSchedule(
        id: 3,
        dateTime: DateTime(2025, 6, 1, 17, 0),
        stadium: '사직',
        homeTeam: 'SSG',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.finished,
        homeScore: 4,
        awayScore: 3,
      ),
      GameSchedule(
        id: 4,
        dateTime: DateTime(2025, 6, 1, 17, 0),
        stadium: '창원',
        homeTeam: '한화',
        awayTeam: 'NC',
        homeTeamLogo: getTeamLogo('한화'),
        awayTeamLogo: getTeamLogo('NC'),
        status: GameStatus.finished,
        homeScore: 5,
        awayScore: 16,
      ),
      GameSchedule(
        id: 5,
        dateTime: DateTime(2025, 6, 1, 17, 0),
        stadium: '수원',
        homeTeam: 'KIA',
        awayTeam: 'KT',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('KT'),
        status: GameStatus.finished,
        homeScore: 5,
        awayScore: 3,
      ),
      GameSchedule(
        id: 6,
        dateTime: DateTime(2025, 6, 3, 14, 0),
        stadium: '창원',
        homeTeam: 'LG',
        awayTeam: 'NC',
        homeTeamLogo: getTeamLogo('LG'),
        awayTeamLogo: getTeamLogo('NC'),
        status: GameStatus.finished,
        homeScore: 15,
        awayScore: 0,
      ),
      GameSchedule(
        id: 7,
        dateTime: DateTime(2025, 6, 3, 14, 0),
        stadium: '대전(신)',
        homeTeam: 'KT',
        awayTeam: '한화',
        homeTeamLogo: getTeamLogo('KT'),
        awayTeamLogo: getTeamLogo('한화'),
        status: GameStatus.finished,
        homeScore: 1,
        awayScore: 10,
      ),
      GameSchedule(
        id: 8,
        dateTime: DateTime(2025, 6, 3, 17, 0),
        stadium: '잠실',
        homeTeam: 'KIA',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.finished,
        homeScore: 11,
        awayScore: 3,
      ),
      GameSchedule(
        id: 9,
        dateTime: DateTime(2025, 6, 3, 17, 0),
        stadium: '문학',
        homeTeam: '삼성',
        awayTeam: 'SSG',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('SSG'),
        status: GameStatus.finished,
        homeScore: 4,
        awayScore: 6,
      ),
      GameSchedule(
        id: 10,
        dateTime: DateTime(2025, 6, 3, 17, 0),
        stadium: '사직',
        homeTeam: '키움',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('키움'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.finished,
        homeScore: 0,
        awayScore: 8,
      ),
      GameSchedule(
        id: 11,
        dateTime: DateTime(2025, 6, 4, 18, 30),
        stadium: '잠실',
        homeTeam: 'KIA',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.finished,
        homeScore: 8,
        awayScore: 3,
      ),
      GameSchedule(
        id: 12,
        dateTime: DateTime(2025, 6, 4, 18, 30),
        stadium: '문학',
        homeTeam: '삼성',
        awayTeam: 'SSG',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('SSG'),
        status: GameStatus.finished,
        homeScore: 1,
        awayScore: 4,
      ),
      GameSchedule(
        id: 13,
        dateTime: DateTime(2025, 6, 4, 18, 30),
        stadium: '사직',
        homeTeam: '키움',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('키움'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.finished,
        homeScore: 9,
        awayScore: 6,
      ),
      GameSchedule(
        id: 14,
        dateTime: DateTime(2025, 6, 4, 18, 30),
        stadium: '창원',
        homeTeam: 'LG',
        awayTeam: 'NC',
        homeTeamLogo: getTeamLogo('LG'),
        awayTeamLogo: getTeamLogo('NC'),
        status: GameStatus.finished,
        homeScore: 5,
        awayScore: 6,
      ),
      GameSchedule(
        id: 15,
        dateTime: DateTime(2025, 6, 4, 18, 30),
        stadium: '대전(신)',
        homeTeam: 'KT',
        awayTeam: '한화',
        homeTeamLogo: getTeamLogo('KT'),
        awayTeamLogo: getTeamLogo('한화'),
        status: GameStatus.finished,
        homeScore: 3,
        awayScore: 4,
      ),
      GameSchedule(
        id: 16,
        dateTime: DateTime(2025, 6, 5, 18, 30),
        stadium: '잠실',
        homeTeam: 'KIA',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.finished,
        homeScore: 1,
        awayScore: 2,
      ),
      GameSchedule(
        id: 17,
        dateTime: DateTime(2025, 6, 5, 18, 30),
        stadium: '문학',
        homeTeam: '삼성',
        awayTeam: 'SSG',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('SSG'),
        status: GameStatus.finished,
        homeScore: 3,
        awayScore: 1,
      ),
      GameSchedule(
        id: 18,
        dateTime: DateTime(2025, 6, 5, 18, 30),
        stadium: '사직',
        homeTeam: '키움',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('키움'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.finished,
        homeScore: 10,
        awayScore: 5,
      ),
      GameSchedule(
        id: 19,
        dateTime: DateTime(2025, 6, 5, 18, 30),
        stadium: '창원',
        homeTeam: 'LG',
        awayTeam: 'NC',
        homeTeamLogo: getTeamLogo('LG'),
        awayTeamLogo: getTeamLogo('NC'),
        status: GameStatus.finished,
        homeScore: 3,
        awayScore: 1,
      ),
      GameSchedule(
        id: 20,
        dateTime: DateTime(2025, 6, 5, 18, 30),
        stadium: '대전(신)',
        homeTeam: 'KT',
        awayTeam: '한화',
        homeTeamLogo: getTeamLogo('KT'),
        awayTeamLogo: getTeamLogo('한화'),
        status: GameStatus.finished,
        homeScore: 7,
        awayScore: 0,
      ),
      GameSchedule(
        id: 21,
        dateTime: DateTime(2025, 6, 6, 17, 0),
        stadium: '잠실',
        homeTeam: '롯데',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('롯데'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.finished,
        homeScore: 2,
        awayScore: 5,
      ),
      // 6월 13일 취소 경기들
      GameSchedule(
        id: 51,
        dateTime: DateTime(2025, 6, 13, 18, 30),
        stadium: '잠실',
        homeTeam: '키움',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('키움'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.canceled,
      ),
      GameSchedule(
        id: 52,
        dateTime: DateTime(2025, 6, 13, 18, 30),
        stadium: '문학',
        homeTeam: '롯데',
        awayTeam: 'SSG',
        homeTeamLogo: getTeamLogo('롯데'),
        awayTeamLogo: getTeamLogo('SSG'),
        status: GameStatus.canceled,
      ),

      // 6월 14일 경기들
      GameSchedule(
        id: 53,
        dateTime: DateTime(2025, 6, 14, 14, 0),
        stadium: '잠실',
        homeTeam: 'LG',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('LG'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.finished,
        homeScore: 8,
        awayScore: 4,
      ),
      GameSchedule(
        id: 54,
        dateTime: DateTime(2025, 6, 14, 17, 0),
        stadium: '문학',
        homeTeam: 'SSG',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.finished,
        homeScore: 6,
        awayScore: 3,
      ),
      GameSchedule(
        id: 55,
        dateTime: DateTime(2025, 6, 14, 17, 0),
        stadium: '사직',
        homeTeam: '롯데',
        awayTeam: 'KIA',
        homeTeamLogo: getTeamLogo('롯데'),
        awayTeamLogo: getTeamLogo('KIA'),
        status: GameStatus.finished,
        homeScore: 2,
        awayScore: 7,
      ),
      GameSchedule(
        id: 56,
        dateTime: DateTime(2025, 6, 14, 17, 0),
        stadium: '창원',
        homeTeam: 'NC',
        awayTeam: '한화',
        homeTeamLogo: getTeamLogo('NC'),
        awayTeamLogo: getTeamLogo('한화'),
        status: GameStatus.finished,
        homeScore: 5,
        awayScore: 2,
      ),
      GameSchedule(
        id: 57,
        dateTime: DateTime(2025, 6, 14, 17, 0),
        stadium: '수원',
        homeTeam: 'KT',
        awayTeam: '삼성',
        homeTeamLogo: getTeamLogo('KT'),
        awayTeamLogo: getTeamLogo('삼성'),
        status: GameStatus.finished,
        homeScore: 1,
        awayScore: 3,
      ),

      // 6월 15일 경기들
      GameSchedule(
        id: 58,
        dateTime: DateTime(2025, 6, 15, 14, 0),
        stadium: '잠실',
        homeTeam: 'LG',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('LG'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.finished,
        homeScore: 5,
        awayScore: 8,
      ),
      GameSchedule(
        id: 59,
        dateTime: DateTime(2025, 6, 15, 17, 0),
        stadium: '문학',
        homeTeam: 'SSG',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.finished,
        homeScore: 4,
        awayScore: 1,
      ),
      GameSchedule(
        id: 60,
        dateTime: DateTime(2025, 6, 15, 17, 0),
        stadium: '사직',
        homeTeam: '롯데',
        awayTeam: 'KIA',
        homeTeamLogo: getTeamLogo('롯데'),
        awayTeamLogo: getTeamLogo('KIA'),
        status: GameStatus.finished,
        homeScore: 6,
        awayScore: 9,
      ),
      GameSchedule(
        id: 61,
        dateTime: DateTime(2025, 6, 15, 17, 0),
        stadium: '창원',
        homeTeam: 'NC',
        awayTeam: '한화',
        homeTeamLogo: getTeamLogo('NC'),
        awayTeamLogo: getTeamLogo('한화'),
        status: GameStatus.finished,
        homeScore: 8,
        awayScore: 5,
      ),
      GameSchedule(
        id: 62,
        dateTime: DateTime(2025, 6, 15, 17, 0),
        stadium: '수원',
        homeTeam: 'KT',
        awayTeam: '삼성',
        homeTeamLogo: getTeamLogo('KT'),
        awayTeamLogo: getTeamLogo('삼성'),
        status: GameStatus.finished,
        homeScore: 4,
        awayScore: 2,
      ),

      // 6월 16일 경기들
      GameSchedule(
        id: 63,
        dateTime: DateTime(2025, 6, 16, 18, 30),
        stadium: '고척',
        homeTeam: '키움',
        awayTeam: 'LG',
        homeTeamLogo: getTeamLogo('키움'),
        awayTeamLogo: getTeamLogo('LG'),
        status: GameStatus.finished,
        homeScore: 3,
        awayScore: 7,
      ),
      GameSchedule(
        id: 64,
        dateTime: DateTime(2025, 6, 16, 18, 30),
        stadium: '문학',
        homeTeam: 'SSG',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.finished,
        homeScore: 2,
        awayScore: 5,
      ),
      GameSchedule(
        id: 65,
        dateTime: DateTime(2025, 6, 16, 18, 30),
        stadium: '대구',
        homeTeam: '삼성',
        awayTeam: 'KIA',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('KIA'),
        status: GameStatus.finished,
        homeScore: 4,
        awayScore: 6,
      ),
      GameSchedule(
        id: 66,
        dateTime: DateTime(2025, 6, 16, 18, 30),
        stadium: '창원',
        homeTeam: 'NC',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('NC'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.finished,
        homeScore: 7,
        awayScore: 3,
      ),
      GameSchedule(
        id: 67,
        dateTime: DateTime(2025, 6, 16, 18, 30),
        stadium: '대전(신)',
        homeTeam: '한화',
        awayTeam: 'KT',
        homeTeamLogo: getTeamLogo('한화'),
        awayTeamLogo: getTeamLogo('KT'),
        status: GameStatus.finished,
        homeScore: 1,
        awayScore: 8,
      ),

      // 6월 17일 경기들
      GameSchedule(
        id: 68,
        dateTime: DateTime(2025, 6, 17, 18, 30),
        stadium: '고척',
        homeTeam: '키움',
        awayTeam: 'LG',
        homeTeamLogo: getTeamLogo('키움'),
        awayTeamLogo: getTeamLogo('LG'),
        status: GameStatus.finished,
        homeScore: 5,
        awayScore: 4,
      ),
      GameSchedule(
        id: 69,
        dateTime: DateTime(2025, 6, 17, 18, 30),
        stadium: '문학',
        homeTeam: 'SSG',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.finished,
        homeScore: 6,
        awayScore: 2,
      ),
      GameSchedule(
        id: 70,
        dateTime: DateTime(2025, 6, 17, 18, 30),
        stadium: '대구',
        homeTeam: '삼성',
        awayTeam: 'KIA',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('KIA'),
        status: GameStatus.finished,
        homeScore: 3,
        awayScore: 8,
      ),
      GameSchedule(
        id: 71,
        dateTime: DateTime(2025, 6, 17, 18, 30),
        stadium: '창원',
        homeTeam: 'NC',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('NC'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.finished,
        homeScore: 4,
        awayScore: 7,
      ),
      GameSchedule(
        id: 72,
        dateTime: DateTime(2025, 6, 17, 18, 30),
        stadium: '대전(신)',
        homeTeam: '한화',
        awayTeam: 'KT',
        homeTeamLogo: getTeamLogo('한화'),
        awayTeamLogo: getTeamLogo('KT'),
        status: GameStatus.finished,
        homeScore: 9,
        awayScore: 6,
      ),

      // 6월 18일 경기들
      GameSchedule(
        id: 73,
        dateTime: DateTime(2025, 6, 18, 18, 30),
        stadium: '고척',
        homeTeam: '키움',
        awayTeam: 'LG',
        homeTeamLogo: getTeamLogo('키움'),
        awayTeamLogo: getTeamLogo('LG'),
        status: GameStatus.finished,
        homeScore: 2,
        awayScore: 11,
      ),
      GameSchedule(
        id: 74,
        dateTime: DateTime(2025, 6, 18, 18, 30),
        stadium: '문학',
        homeTeam: 'SSG',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.finished,
        homeScore: 8,
        awayScore: 3,
      ),
      GameSchedule(
        id: 75,
        dateTime: DateTime(2025, 6, 18, 18, 30),
        stadium: '대구',
        homeTeam: '삼성',
        awayTeam: 'KIA',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('KIA'),
        status: GameStatus.finished,
        homeScore: 5,
        awayScore: 7,
      ),

      // 오늘(6월 19일) 경기들 - scheduled 상태
      GameSchedule(
        id: 76,
        dateTime: DateTime(2025, 6, 19, 18, 30),
        stadium: '잠실',
        homeTeam: 'NC',
        awayTeam: 'LG',
        homeTeamLogo: getTeamLogo('NC'),
        awayTeamLogo: getTeamLogo('LG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 77,
        dateTime: DateTime(2025, 6, 19, 18, 30),
        stadium: '사직',
        homeTeam: '한화',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('한화'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 78,
        dateTime: DateTime(2025, 6, 19, 18, 30),
        stadium: '대구',
        homeTeam: '두산',
        awayTeam: '삼성',
        homeTeamLogo: getTeamLogo('두산'),
        awayTeamLogo: getTeamLogo('삼성'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 79,
        dateTime: DateTime(2025, 6, 19, 18, 30),
        stadium: '광주',
        homeTeam: 'KT',
        awayTeam: 'KIA',
        homeTeamLogo: getTeamLogo('KT'),
        awayTeamLogo: getTeamLogo('KIA'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 80,
        dateTime: DateTime(2025, 6, 19, 18, 30),
        stadium: '고척',
        homeTeam: 'SSG',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.scheduled,
      ),
      // 미래 경기들 중 일부 (6월 20일)
      GameSchedule(
        id: 81,
        dateTime: DateTime(2025, 6, 20, 18, 30),
        stadium: '잠실',
        homeTeam: '두산',
        awayTeam: 'LG',
        homeTeamLogo: getTeamLogo('두산'),
        awayTeamLogo: getTeamLogo('LG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 82,
        dateTime: DateTime(2025, 6, 20, 18, 30),
        stadium: '문학',
        homeTeam: 'KIA',
        awayTeam: 'SSG',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('SSG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 83,
        dateTime: DateTime(2025, 6, 20, 18, 30),
        stadium: '사직',
        homeTeam: '삼성',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 84,
        dateTime: DateTime(2025, 6, 20, 18, 30),
        stadium: '수원',
        homeTeam: 'NC',
        awayTeam: 'KT',
        homeTeamLogo: getTeamLogo('NC'),
        awayTeamLogo: getTeamLogo('KT'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 85,
        dateTime: DateTime(2025, 6, 20, 18, 30),
        stadium: '대전(신)',
        homeTeam: '키움',
        awayTeam: '한화',
        homeTeamLogo: getTeamLogo('키움'),
        awayTeamLogo: getTeamLogo('한화'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 86,
        dateTime: DateTime(2025, 6, 21, 17, 0),
        stadium: '잠실',
        homeTeam: '두산',
        awayTeam: 'LG',
        homeTeamLogo: getTeamLogo('두산'),
        awayTeamLogo: getTeamLogo('LG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 87,
        dateTime: DateTime(2025, 6, 21, 17, 0),
        stadium: '문학',
        homeTeam: 'KIA',
        awayTeam: 'SSG',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('SSG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 88,
        dateTime: DateTime(2025, 6, 21, 17, 0),
        stadium: '사직',
        homeTeam: '삼성',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 89,
        dateTime: DateTime(2025, 6, 21, 17, 0),
        stadium: '수원',
        homeTeam: 'NC',
        awayTeam: 'KT',
        homeTeamLogo: getTeamLogo('NC'),
        awayTeamLogo: getTeamLogo('KT'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 90,
        dateTime: DateTime(2025, 6, 21, 17, 0),
        stadium: '대전(신)',
        homeTeam: '키움',
        awayTeam: '한화',
        homeTeamLogo: getTeamLogo('키움'),
        awayTeamLogo: getTeamLogo('한화'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 91,
        dateTime: DateTime(2025, 6, 22, 17, 0),
        stadium: '잠실',
        homeTeam: '두산',
        awayTeam: 'LG',
        homeTeamLogo: getTeamLogo('두산'),
        awayTeamLogo: getTeamLogo('LG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 92,
        dateTime: DateTime(2025, 6, 22, 17, 0),
        stadium: '문학',
        homeTeam: 'KIA',
        awayTeam: 'SSG',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('SSG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 93,
        dateTime: DateTime(2025, 6, 22, 17, 0),
        stadium: '사직',
        homeTeam: '삼성',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 94,
        dateTime: DateTime(2025, 6, 22, 17, 0),
        stadium: '수원',
        homeTeam: 'NC',
        awayTeam: 'KT',
        homeTeamLogo: getTeamLogo('NC'),
        awayTeamLogo: getTeamLogo('KT'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 95,
        dateTime: DateTime(2025, 6, 22, 17, 0),
        stadium: '대전(신)',
        homeTeam: '키움',
        awayTeam: '한화',
        homeTeamLogo: getTeamLogo('키움'),
        awayTeamLogo: getTeamLogo('한화'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 96,
        dateTime: DateTime(2025, 6, 24, 18, 30),
        stadium: '잠실',
        homeTeam: 'SSG',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 97,
        dateTime: DateTime(2025, 6, 24, 18, 30),
        stadium: '대구',
        homeTeam: '한화',
        awayTeam: '삼성',
        homeTeamLogo: getTeamLogo('한화'),
        awayTeamLogo: getTeamLogo('삼성'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 98,
        dateTime: DateTime(2025, 6, 24, 18, 30),
        stadium: '창원',
        homeTeam: '롯데',
        awayTeam: 'NC',
        homeTeamLogo: getTeamLogo('롯데'),
        awayTeamLogo: getTeamLogo('NC'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 99,
        dateTime: DateTime(2025, 6, 24, 18, 30),
        stadium: '수원',
        homeTeam: 'LG',
        awayTeam: 'KT',
        homeTeamLogo: getTeamLogo('LG'),
        awayTeamLogo: getTeamLogo('KT'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 100,
        dateTime: DateTime(2025, 6, 24, 18, 30),
        stadium: '고척',
        homeTeam: 'KIA',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 101,
        dateTime: DateTime(2025, 6, 25, 18, 30),
        stadium: '잠실',
        homeTeam: 'SSG',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 102,
        dateTime: DateTime(2025, 6, 25, 18, 30),
        stadium: '대구',
        homeTeam: '한화',
        awayTeam: '삼성',
        homeTeamLogo: getTeamLogo('한화'),
        awayTeamLogo: getTeamLogo('삼성'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 103,
        dateTime: DateTime(2025, 6, 25, 18, 30),
        stadium: '창원',
        homeTeam: '롯데',
        awayTeam: 'NC',
        homeTeamLogo: getTeamLogo('롯데'),
        awayTeamLogo: getTeamLogo('NC'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 104,
        dateTime: DateTime(2025, 6, 25, 18, 30),
        stadium: '수원',
        homeTeam: 'LG',
        awayTeam: 'KT',
        homeTeamLogo: getTeamLogo('LG'),
        awayTeamLogo: getTeamLogo('KT'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 105,
        dateTime: DateTime(2025, 6, 25, 18, 30),
        stadium: '고척',
        homeTeam: 'KIA',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 106,
        dateTime: DateTime(2025, 6, 26, 18, 30),
        stadium: '잠실',
        homeTeam: 'SSG',
        awayTeam: '두산',
        homeTeamLogo: getTeamLogo('SSG'),
        awayTeamLogo: getTeamLogo('두산'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 107,
        dateTime: DateTime(2025, 6, 26, 18, 30),
        stadium: '대구',
        homeTeam: '한화',
        awayTeam: '삼성',
        homeTeamLogo: getTeamLogo('한화'),
        awayTeamLogo: getTeamLogo('삼성'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 108,
        dateTime: DateTime(2025, 6, 26, 18, 30),
        stadium: '창원',
        homeTeam: '롯데',
        awayTeam: 'NC',
        homeTeamLogo: getTeamLogo('롯데'),
        awayTeamLogo: getTeamLogo('NC'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 109,
        dateTime: DateTime(2025, 6, 26, 18, 30),
        stadium: '수원',
        homeTeam: 'LG',
        awayTeam: 'KT',
        homeTeamLogo: getTeamLogo('LG'),
        awayTeamLogo: getTeamLogo('KT'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 110,
        dateTime: DateTime(2025, 6, 26, 18, 30),
        stadium: '고척',
        homeTeam: 'KIA',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 111,
        dateTime: DateTime(2025, 6, 27, 18, 30),
        stadium: '잠실',
        homeTeam: 'KIA',
        awayTeam: 'LG',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('LG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 112,
        dateTime: DateTime(2025, 6, 27, 18, 30),
        stadium: '문학',
        homeTeam: '한화',
        awayTeam: 'SSG',
        homeTeamLogo: getTeamLogo('한화'),
        awayTeamLogo: getTeamLogo('SSG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 113,
        dateTime: DateTime(2025, 6, 27, 18, 30),
        stadium: '사직',
        homeTeam: 'KT',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('KT'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 114,
        dateTime: DateTime(2025, 6, 27, 18, 30),
        stadium: '창원',
        homeTeam: '두산',
        awayTeam: 'NC',
        homeTeamLogo: getTeamLogo('두산'),
        awayTeamLogo: getTeamLogo('NC'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 115,
        dateTime: DateTime(2025, 6, 27, 18, 30),
        stadium: '고척',
        homeTeam: '삼성',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 116,
        dateTime: DateTime(2025, 6, 28, 17, 0),
        stadium: '잠실',
        homeTeam: 'KIA',
        awayTeam: 'LG',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('LG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 117,
        dateTime: DateTime(2025, 6, 28, 17, 0),
        stadium: '문학',
        homeTeam: '한화',
        awayTeam: 'SSG',
        homeTeamLogo: getTeamLogo('한화'),
        awayTeamLogo: getTeamLogo('SSG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 118,
        dateTime: DateTime(2025, 6, 28, 17, 0),
        stadium: '사직',
        homeTeam: 'KT',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('KT'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 119,
        dateTime: DateTime(2025, 6, 28, 17, 0),
        stadium: '창원',
        homeTeam: '두산',
        awayTeam: 'NC',
        homeTeamLogo: getTeamLogo('두산'),
        awayTeamLogo: getTeamLogo('NC'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 120,
        dateTime: DateTime(2025, 6, 28, 17, 0),
        stadium: '고척',
        homeTeam: '삼성',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 121,
        dateTime: DateTime(2025, 6, 29, 14, 0),
        stadium: '고척',
        homeTeam: '삼성',
        awayTeam: '키움',
        homeTeamLogo: getTeamLogo('삼성'),
        awayTeamLogo: getTeamLogo('키움'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 122,
        dateTime: DateTime(2025, 6, 29, 17, 0),
        stadium: '잠실',
        homeTeam: 'KIA',
        awayTeam: 'LG',
        homeTeamLogo: getTeamLogo('KIA'),
        awayTeamLogo: getTeamLogo('LG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 123,
        dateTime: DateTime(2025, 6, 29, 17, 0),
        stadium: '문학',
        homeTeam: '한화',
        awayTeam: 'SSG',
        homeTeamLogo: getTeamLogo('한화'),
        awayTeamLogo: getTeamLogo('SSG'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 124,
        dateTime: DateTime(2025, 6, 29, 17, 0),
        stadium: '사직',
        homeTeam: 'KT',
        awayTeam: '롯데',
        homeTeamLogo: getTeamLogo('KT'),
        awayTeamLogo: getTeamLogo('롯데'),
        status: GameStatus.scheduled,
      ),
      GameSchedule(
        id: 125,
        dateTime: DateTime(2025, 6, 29, 17, 0),
        stadium: '창원',
        homeTeam: '두산',
        awayTeam: 'NC',
        homeTeamLogo: getTeamLogo('두산'),
        awayTeamLogo: getTeamLogo('NC'),
        status: GameStatus.scheduled,
      ),
    ];
    
    // 샘플 데이터 생성 (레거시 - 현재는 사용하지 않음)
  List<GameSchedule> _generateMonthSampleData() {
    return _generateCurrentMonthSampleData();
  }
}

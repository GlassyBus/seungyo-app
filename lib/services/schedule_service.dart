import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/team_data.dart';
import '../models/game_schedule.dart';
import '../services/record_service.dart';

/// 경기 일정 관리 서비스
class ScheduleService {
  static const String _fileName = 'game_schedules.json';

  // 싱글톤 패턴 구현
  static final ScheduleService _instance = ScheduleService._internal();

  factory ScheduleService() => _instance;

  ScheduleService._internal();

  // 월별 캐시 (메모리 캐시)
  final Map<String, List<GameSchedule>> _monthlyCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // 캐시 유효 시간 (1시간)
  static const Duration _cacheValidDuration = Duration(hours: 1);

  /// 캐시 키 생성
  String _getCacheKey(int year, int month) {
    return '${year}_${month.toString().padLeft(2, '0')}';
  }

  /// 캐시가 유효한지 확인
  bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheValidDuration;
  }

  /// 캐시에서 데이터 가져오기
  List<GameSchedule>? _getFromCache(int year, int month) {
    final cacheKey = _getCacheKey(year, month);

    if (_isCacheValid(cacheKey)) {
      if (kDebugMode) {
        print(
          '✅ 캐시에서 ${year}년 ${month}월 데이터 반환 (${_monthlyCache[cacheKey]?.length ?? 0}개)',
        );
      }
      return _monthlyCache[cacheKey];
    }

    // 캐시가 무효하면 제거
    _monthlyCache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
    return null;
  }

  /// 캐시에 데이터 저장
  void _saveToCache(int year, int month, List<GameSchedule> schedules) {
    final cacheKey = _getCacheKey(year, month);
    _monthlyCache[cacheKey] = schedules;
    _cacheTimestamps[cacheKey] = DateTime.now();

    if (kDebugMode) {
      print('💾 ${year}년 ${month}월 데이터 캐시 저장 (${schedules.length}개)');
    }
  }

  /// 캐시 초기화
  void clearCache() {
    _monthlyCache.clear();
    _cacheTimestamps.clear();
    if (kDebugMode) {
      print('🗑️ 경기 일정 캐시 초기화');
    }
  }

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
        print('🔄 ${year}년 ${month}월 경기 일정 요청...');
      }

      // 1. 먼저 캐시에서 확인
      final cachedData = _getFromCache(year, month);
      if (cachedData != null) {
        return cachedData;
      }

      if (kDebugMode) {
        print('🌐 ${year}년 ${month}월 경기 일정 API 호출 중...');
      }

      // 2. 캐시에 없으면 실제 API에서 데이터 가져오기 시도
      List<GameSchedule> schedules = await _fetchFromRealKBOAPI(year, month);

      // 3. API 호출 실패 시 샘플 데이터 사용
      if (schedules.isEmpty) {
        if (kDebugMode) {
          print('⚠️ API 호출 실패, 샘플 데이터 사용');
        }
        // schedules = _generateSampleDataForMonth(year, month);
      }

      if (kDebugMode) {
        print('✅ ${schedules.length}개 경기 일정 로드 성공');
      }

      // 4. 캐시에 저장
      _saveToCache(year, month, schedules);

      // 5. 로컬 파일에도 저장 (백업용)
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

  /// 실제 KBO API에서 데이터 가져오기
  Future<List<GameSchedule>> _fetchFromRealKBOAPI(int year, int month) async {
    try {
      // 1. KBO Stats API 사용 (가장 안정적)
      final kboStatsSchedules = await _fetchFromKBOStatsAPI(year, month);
      if (kboStatsSchedules.isNotEmpty) {
        return kboStatsSchedules;
      }

      // 2. 네이버 스포츠 API 사용
      final naverSchedules = await _fetchNaverSchedules(year, month);
      if (naverSchedules.isNotEmpty) {
        return naverSchedules;
      }

      // 모든 API 실패 시 빈 리스트 반환
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ 실제 API 호출 실패: $e');
      }
      return [];
    }
  }

  /// KBO Stats API에서 데이터 가져오기 (비공식이지만 가장 안정적)
  Future<List<GameSchedule>> _fetchFromKBOStatsAPI(int year, int month) async {
    try {
      // KBO Stats는 월별로 데이터를 제공
      final url =
          'https://www.koreabaseball.com/ws/Main.asmx/GetScheduleList'
          '?gameDate=${year}${month.toString().padLeft(2, '0')}01'
          '&gameDate2=${year}${month.toString().padLeft(2, '0')}31'
          '&season=$year';

      if (kDebugMode) {
        print('🌐 KBO Stats API 호출: $url');
      }

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Referer': 'https://www.koreabaseball.com',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseKBOStatsData(data, year, month);
      } else {
        if (kDebugMode) {
          print('❌ KBO Stats API 응답 실패: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ KBO Stats API 호출 에러: $e');
      }
      return [];
    }
  }

  /// KBO Stats 데이터 파싱
  List<GameSchedule> _parseKBOStatsData(
    Map<String, dynamic> data,
    int year,
    int month,
  ) {
    final schedules = <GameSchedule>[];

    try {
      final gameList = data['d'] as List?;
      if (gameList == null) return schedules;

      int gameId = 1;

      for (final game in gameList) {
        final gameData = game as Map<String, dynamic>;

        // 날짜 및 시간 파싱
        final gameDate = gameData['GameDate'] as String?;
        final gameTime = gameData['GameTime'] as String? ?? '18:30';

        if (gameDate == null) continue;

        final gameDateTime = _parseKBODateTime(gameDate, gameTime);
        if (gameDateTime == null) continue;

        // 해당 월 경기만 필터링
        if (gameDateTime.year != year || gameDateTime.month != month) {
          continue;
        }

        // 팀 정보
        final homeTeamName = _normalizeKBOTeamName(
          gameData['HomeTeam'] as String? ?? '',
        );
        final awayTeamName = _normalizeKBOTeamName(
          gameData['AwayTeam'] as String? ?? '',
        );

        if (homeTeamName.isEmpty || awayTeamName.isEmpty) continue;

        // 경기장 정보
        final stadium = _normalizeStadiumName(
          gameData['Stadium'] as String? ?? '',
        );

        // 경기 상태 및 점수
        final gameStatus = _parseKBOGameStatus(
          gameData['GameStatus'] as String?,
        );
        final homeScore = int.tryParse(gameData['HomeScore'] as String? ?? '');
        final awayScore = int.tryParse(gameData['AwayScore'] as String? ?? '');

        schedules.add(
          GameSchedule(
            id: gameId++,
            dateTime: gameDateTime,
            stadium: stadium,
            homeTeam: homeTeamName,
            awayTeam: awayTeamName,
            homeTeamLogo: getTeamLogo(homeTeamName),
            awayTeamLogo: getTeamLogo(awayTeamName),
            status: gameStatus,
            homeScore: homeScore,
            awayScore: awayScore,
          ),
        );
      }

      if (kDebugMode) {
        print('✅ KBO Stats에서 ${schedules.length}개 경기 파싱 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ KBO Stats 데이터 파싱 에러: $e');
      }
    }

    return schedules;
  }

  /// Sports Open 데이터 파싱
  List<GameSchedule> _parseSportsOpenData(
    Map<String, dynamic> data,
    int year,
    int month,
  ) {
    final schedules = <GameSchedule>[];

    try {
      final games = data['games'] as List?;
      if (games == null) return schedules;

      int gameId = 1;

      for (final game in games) {
        final gameData = game as Map<String, dynamic>;

        // 날짜 파싱
        final schedule = gameData['schedule'] as Map<String, dynamic>?;
        final startTime = schedule?['startTime'] as String?;

        if (startTime == null) continue;

        final gameDateTime = DateTime.parse(startTime);

        // 해당 월의 경기만 필터링
        if (gameDateTime.year != year || gameDateTime.month != month) {
          continue;
        }

        // 팀 정보
        final awayTeam = gameData['awayTeam'] as Map<String, dynamic>?;
        final homeTeam = gameData['homeTeam'] as Map<String, dynamic>?;

        final awayTeamName = _normalizeKBOTeamName(
          awayTeam?['abbreviation'] as String? ?? '',
        );
        final homeTeamName = _normalizeKBOTeamName(
          homeTeam?['abbreviation'] as String? ?? '',
        );

        if (homeTeamName.isEmpty || awayTeamName.isEmpty) continue;

        // 경기장 정보
        final venue = gameData['venue'] as Map<String, dynamic>?;
        final stadium = _normalizeStadiumName(venue?['name'] as String? ?? '');

        // 경기 상태
        final playedStatus = gameData['playedStatus'] as String?;
        final gameStatus = _parseSportsOpenGameStatus(playedStatus);

        // 점수 정보
        int? homeScore;
        int? awayScore;

        if (gameStatus == GameStatus.finished ||
            gameStatus == GameStatus.inProgress) {
          final score = gameData['score'] as Map<String, dynamic>?;
          homeScore = score?['homeScoreTotal'] as int?;
          awayScore = score?['awayScoreTotal'] as int?;
        }

        schedules.add(
          GameSchedule(
            id: gameId++,
            dateTime: gameDateTime.toLocal(),
            stadium: stadium,
            homeTeam: homeTeamName,
            awayTeam: awayTeamName,
            homeTeamLogo: getTeamLogo(homeTeamName),
            awayTeamLogo: getTeamLogo(awayTeamName),
            status: gameStatus,
            homeScore: homeScore,
            awayScore: awayScore,
          ),
        );
      }

      if (kDebugMode) {
        print('✅ Sports Open에서 ${schedules.length}개 경기 파싱 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sports Open 데이터 파싱 에러: $e');
      }
    }

    return schedules;
  }

  /// KBO 날짜/시간 파싱
  DateTime? _parseKBODateTime(String dateStr, String timeStr) {
    try {
      // 날짜 형식: 20250620 또는 2025-06-20
      String cleanDateStr = dateStr.replaceAll('-', '');

      if (cleanDateStr.length != 8) return null;

      final year = int.parse(cleanDateStr.substring(0, 4));
      final month = int.parse(cleanDateStr.substring(4, 6));
      final day = int.parse(cleanDateStr.substring(6, 8));

      // 시간 형식: 18:30 또는 1830
      String cleanTimeStr =
          timeStr.contains(':')
              ? timeStr
              : '${timeStr.substring(0, 2)}:${timeStr.substring(2, 4)}';
      final timeParts = cleanTimeStr.split(':');
      final hour = timeParts.isNotEmpty ? int.parse(timeParts[0]) : 18;
      final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 30;

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 날짜/시간 파싱 에러: $e');
      }
      return null;
    }
  }

  /// KBO 팀명 정규화
  String _normalizeKBOTeamName(String teamName) {
    final teamMapping = {
      '두산': '두산',
      'DOOSAN': '두산',
      'Bears': '두산',
      'LG': 'LG',
      'Twins': 'LG',
      'SSG': 'SSG',
      'Landers': 'SSG',
      '키움': '키움',
      'KIWOOM': '키움',
      'Heroes': '키움',
      'KIA': 'KIA',
      'Tigers': 'KIA',
      '롯데': '롯데',
      'LOTTE': '롯데',
      'Giants': '롯데',
      'NC': 'NC',
      'Dinos': 'NC',
      '삼성': '삼성',
      'SAMSUNG': '삼성',
      'Lions': '삼성',
      '한화': '한화',
      'HANWHA': '한화',
      'Eagles': '한화',
      'KT': 'KT',
      'Wiz': 'KT',
    };

    return teamMapping[teamName.toUpperCase()] ??
        teamMapping[teamName] ??
        teamName;
  }

  /// 경기장명 정규화
  String _normalizeStadiumName(String stadiumName) {
    final stadiumMapping = {
      '잠실야구장': '잠실',
      '잠실': '잠실',
      'Jamsil': '잠실',
      'Jamsil Baseball Stadium': '잠실',
      '고척스카이돔': '고척',
      '고척': '고척',
      'Gocheok': '고척',
      'Gocheok Sky Dome': '고척',
      'SSG랜더스필드': '문학',
      '문학': '문학',
      'Incheon': '문학',
      'Incheon SSG Landers Field': '문학',
      '사직야구장': '사직',
      '사직': '사직',
      'Sajik': '사직',
      'Sajik Baseball Stadium': '사직',
      '대구삼성라이온즈파크': '대구',
      '대구': '대구',
      'Daegu': '대구',
      'Daegu Samsung Lions Park': '대구',
      'KIA챔피언스필드': '광주',
      '광주': '광주',
      'Gwangju': '광주',
      'Gwangju-Kia Champions Field': '광주',
      'NC파크': '창원',
      '창원': '창원',
      'Changwon': '창원',
      'Changwon NC Park': '창원',
      '한화생명이글스파크': '대전',
      '대전': '대전',
      'Daejeon': '대전',
      'Hanwha Life Eagles Park': '대전',
      'KT위즈파크': '수원',
      '수원': '수원',
      'Suwon': '수원',
      'Suwon KT Wiz Park': '수원',
    };

    return stadiumMapping[stadiumName] ?? stadiumName;
  }

  /// KBO 경기 상태 파싱
  GameStatus _parseKBOGameStatus(String? statusCode) {
    if (statusCode == null) return GameStatus.scheduled;

    switch (statusCode.toUpperCase()) {
      case 'SCHEDULED':
      case '예정':
      case '1':
        return GameStatus.scheduled;
      case 'INPROGRESS':
      case 'LIVE':
      case '진행중':
      case '2':
        return GameStatus.inProgress;
      case 'FINAL':
      case 'COMPLETED':
      case '종료':
      case '3':
        return GameStatus.finished;
      case 'CANCELED':
      case 'CANCELLED':
      case '취소':
      case '4':
        return GameStatus.canceled;
      case 'POSTPONED':
      case '연기':
      case '5':
        return GameStatus.postponed;
      default:
        return GameStatus.scheduled;
    }
  }

  /// Sports Open 경기 상태 파싱
  GameStatus _parseSportsOpenGameStatus(String? playedStatus) {
    if (playedStatus == null) return GameStatus.scheduled;

    switch (playedStatus.toUpperCase()) {
      case 'UNPLAYED':
        return GameStatus.scheduled;
      case 'LIVE':
        return GameStatus.inProgress;
      case 'COMPLETED':
        return GameStatus.finished;
      case 'CANCELED':
        return GameStatus.canceled;
      case 'POSTPONED':
        return GameStatus.postponed;
      default:
        return GameStatus.scheduled;
    }
  }

  /// 날짜 포맷팅 (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

      final monthSchedules = await getSchedulesByMonth(date.year, date.month);
      if (kDebugMode) {
        print(
          'ScheduleService: Total schedules loaded: ${monthSchedules.length}',
        );
      }

      final filteredSchedules =
          monthSchedules
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

  /// 네이버 스포츠에서 경기 일정 가져오기 (HTML 파싱 대신 API 사용)
  Future<List<GameSchedule>> _fetchNaverSchedules(int year, int month) async {
    try {
      // 해당 월의 첫 번째 날짜로 API 호출
      final date = DateTime(year, month, 1);
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      final url =
          'https://api-gw.sports.naver.com/schedule/calendar?upperCategoryId=kbaseball&categoryIds=kbo&date=$dateString';

      print('네이버 캘린더 API 호출: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print('네이버 캘린더 API 호출 실패: ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);

      if (data['success'] != true || data['result'] == null) {
        print('네이버 캘린더 API 응답 오류: ${data['code']}');
        return [];
      }

      final result = data['result'];
      final dates = result['dates'] as List<dynamic>?;

      print('datadatadatadatadatadata ${dates}');
      if (dates == null) {
        print('네이버 캘린더 API: 날짜 데이터가 없습니다');
        return [];
      }

      List<GameSchedule> schedules = [];
      int gameIdCounter = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      for (final dateInfo in dates) {
        final ymd = dateInfo['ymd'] as String?;
        final gameInfos = dateInfo['gameInfos'] as List<dynamic>?;

        if (ymd == null || gameInfos == null || gameInfos.isEmpty) {
          continue;
        }

        // 요청한 년월과 일치하는지 확인
        final gameDate = DateTime.parse(ymd);
        if (gameDate.year != year || gameDate.month != month) {
          continue;
        }

        for (final gameInfo in gameInfos) {
          try {
            final gameId = gameInfo['gameId'] as String?;
            final homeTeamCode = gameInfo['homeTeamCode'] as String?;
            final awayTeamCode = gameInfo['awayTeamCode'] as String?;
            final statusCode = gameInfo['statusCode'] as String?;
            final winner = gameInfo['winner'] as String?;

            if (gameId == null ||
                homeTeamCode == null ||
                awayTeamCode == null) {
              print(
                '네이버 캘린더: 필수 정보 누락 - gameId: $gameId, home: $homeTeamCode, away: $awayTeamCode',
              );
              continue;
            }

            // 팀 이름 변환
            final homeTeam = _mapNaverTeamCode(homeTeamCode);
            final awayTeam = _mapNaverTeamCode(awayTeamCode);

            // 경기 상태 변환
            GameStatus gameStatus;
            int? homeScore;
            int? awayScore;

            switch (statusCode) {
              case 'BEFORE':
                gameStatus = GameStatus.scheduled;
                break;
              case 'RESULT':
                gameStatus = GameStatus.finished;
                // 승부 결과에 따른 스코어 설정 (실제 스코어는 별도 API 필요)
                if (winner == 'HOME') {
                  homeScore = 5; // 임시 점수
                  awayScore = 3;
                } else if (winner == 'AWAY') {
                  homeScore = 3;
                  awayScore = 5;
                } else if (winner == 'DRAW') {
                  homeScore = 4;
                  awayScore = 4;
                }
                break;
              case 'LIVE':
                gameStatus = GameStatus.inProgress;
                break;
              default:
                gameStatus = GameStatus.scheduled;
            }

            // 경기장 정보
            final stadium = _getDefaultStadium(homeTeam);

            // 기본 시간을 14:00으로 설정 (오후 2시)
            final gameDateTime = DateTime(
              gameDate.year,
              gameDate.month,
              gameDate.day,
              14,
              0,
            );

            final schedule = GameSchedule(
              id: gameIdCounter++,
              dateTime: gameDateTime,
              homeTeam: homeTeam,
              awayTeam: awayTeam,
              stadium: stadium,
              status: gameStatus,
              homeScore: homeScore,
              awayScore: awayScore,
              homeTeamLogo: getTeamLogo(homeTeam),
              awayTeamLogo: getTeamLogo(awayTeam),
            );

            schedules.add(schedule);
            print(
              '네이버 캘린더: 경기 추가 - ${awayTeam} vs ${homeTeam} ($ymd, $statusCode)',
            );
          } catch (e) {
            print('네이버 캘린더: 경기 정보 파싱 오류 - $e');
            continue;
          }
        }
      }

      print('네이버 캘린더: 총 ${schedules.length}개 경기 파싱 완료');
      return schedules;
    } catch (e) {
      print('네이버 캘린더 API 오류: $e');
      return [];
    }
  }

  String _mapNaverTeamCode(String teamCode) {
    switch (teamCode) {
      case 'HH':
        return '한화';
      case 'NC':
        return 'NC';
      case 'HT':
        return 'KIA';
      case 'KT':
        return 'KT';
      case 'SK':
        return 'SSG';
      case 'LT':
        return '롯데';
      case 'SS':
        return '삼성';
      case 'LG':
        return 'LG';
      case 'OB':
        return '두산';
      case 'WO':
        return '키움';
      default:
        return teamCode;
    }
  }

  /// 홈팀 기본 경기장 가져오기
  String _getDefaultStadium(String homeTeam) {
    final stadiumMap = {
      '두산': '잠실',
      'LG': '잠실',
      'SSG': '문학',
      '키움': '고척',
      'KIA': '광주',
      '롯데': '사직',
      'NC': '창원',
      '삼성': '대구',
      '한화': '대전',
      'KT': '수원',
    };

    return stadiumMap[homeTeam] ?? '미정';
  }

  /// 여러 달의 경기 일정을 미리 로드 (백그라운드에서 실행)
  Future<void> preloadSchedules({
    int monthsAhead = 2,
    int monthsBehind = 1,
  }) async {
    final now = DateTime.now();
    final futures = <Future<List<GameSchedule>>>[];

    // 과거 몇 달
    for (int i = monthsBehind; i > 0; i--) {
      final targetDate = DateTime(now.year, now.month - i);
      futures.add(getSchedulesByMonth(targetDate.year, targetDate.month));
    }

    // 현재 달
    futures.add(getSchedulesByMonth(now.year, now.month));

    // 미래 몇 달
    for (int i = 1; i <= monthsAhead; i++) {
      final targetDate = DateTime(now.year, now.month + i);
      futures.add(getSchedulesByMonth(targetDate.year, targetDate.month));
    }

    try {
      await Future.wait(futures);
      if (kDebugMode) {
        print('🚀 ${monthsBehind + 1 + monthsAhead}개월 데이터 미리 로드 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ 일부 월 데이터 미리 로드 실패: $e');
      }
    }
  }

  /// 캐시 상태 확인
  Map<String, dynamic> getCacheStatus() {
    return {
      'cached_months': _monthlyCache.keys.toList(),
      'cache_count': _monthlyCache.length,
      'timestamps': _cacheTimestamps,
    };
  }
}

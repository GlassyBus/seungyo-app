import 'package:flutter/material.dart';

import '../models/game_record.dart';
import '../models/stadium.dart';
import '../models/team.dart';
import '../services/database_service.dart';

/// Mock 데이터 제공자
class MockData {
  MockData._();

  /// DB에서 팀 데이터 가져오기
  static Future<List<Team>> getTeams() async {
    try {
      return await DatabaseService().getTeamsAsAppModels();
    } catch (e) {
      print('Error getting teams from DB: $e');
      // DB에서 가져오지 못할 경우 기본값 반환
      return [
        Team(
          id: '1',
          name: '두산 베어스',
          shortName: '두산',
          primaryColor: Color(0xFF131230),
          secondaryColor: Color(0xFFD4AF37),
          logoUrl: '🐻',
        ),
        Team(
          id: '2',
          name: 'KIA 타이거즈',
          shortName: 'KIA',
          primaryColor: Color(0xFFEA002C),
          secondaryColor: Color(0xFF000000),
          logoUrl: '🐅',
        ),
      ];
    }
  }

  /// DB에서 구장 데이터 가져오기
  static Future<List<Stadium>> getStadiums() async {
    try {
      return await DatabaseService().getStadiumsAsAppModels();
    } catch (e) {
      print('Error getting stadiums from DB: $e');
      // DB에서 가져오지 못할 경우 기본값 반환
      return [Stadium(id: 'jamsil', name: '잠실야구장', city: '서울'), Stadium(id: 'gocheok', name: '고척스카이돔', city: '서울')];
    }
  }

  /// Mock 게임 기록 데이터
  static Future<List<GameRecord>> getGameRecords() async {
    final stadiums = await getStadiums();
    final teams = await getTeams();
    final now = DateTime.now();

    if (stadiums.isEmpty || teams.isEmpty) {
      return [];
    }

    return [
      GameRecord(
        id: 1,
        dateTime: now.subtract(const Duration(days: 1)),
        stadium: stadiums.isNotEmpty ? stadiums[0] : Stadium(id: 'jamsil', name: '잠실야구장', city: '서울'),
        homeTeam:
            teams.isNotEmpty
                ? teams[0]
                : Team(
                  id: '1',
                  name: '두산 베어스',
                  shortName: '두산',
                  primaryColor: Color(0xFF131230),
                  secondaryColor: Color(0xFFD4AF37),
                  logoUrl: '🐻',
                ),
        awayTeam:
            teams.length > 1
                ? teams[1]
                : Team(
                  id: '2',
                  name: 'KIA 타이거즈',
                  shortName: 'KIA',
                  primaryColor: Color(0xFFEA002C),
                  secondaryColor: Color(0xFF000000),
                  logoUrl: '🐅',
                ),
        homeScore: 5,
        awayScore: 3,
        result: GameResult.win,
        seatInfo: '1루 응원석 3층',
        weather: '맑음',
        companions: ['친구1', '친구2'],
        photos: [],
        memo: '홈런이 3개나 나온 경기! 정말 재밌었다.',
        isFavorite: true,
      ),
      GameRecord(
        id: 2,
        dateTime: now.subtract(const Duration(days: 3)),
        stadium: stadiums.isNotEmpty ? stadiums[0] : Stadium(id: 'jamsil', name: '잠실야구장', city: '서울'),
        homeTeam:
            teams.length > 2
                ? teams[2]
                : Team(
                  id: '3',
                  name: 'LG 트윈스',
                  shortName: 'LG',
                  primaryColor: Color(0xFFC30452),
                  secondaryColor: Color(0xFF000000),
                  logoUrl: '⚾',
                ),
        awayTeam:
            teams.isNotEmpty
                ? teams[0]
                : Team(
                  id: '1',
                  name: '두산 베어스',
                  shortName: '두산',
                  primaryColor: Color(0xFF131230),
                  secondaryColor: Color(0xFFD4AF37),
                  logoUrl: '🐻',
                ),
        homeScore: 2,
        awayScore: 4,
        result: GameResult.lose,
        seatInfo: '3루 응원석 2층',
        weather: '흐림',
        companions: ['가족'],
        photos: [],
        memo: '아쉬운 패배... 다음엔 꼭 이기자!',
        isFavorite: false,
      ),
      GameRecord(
        id: 3,
        dateTime: now.subtract(const Duration(days: 7)),
        stadium: stadiums.length > 1 ? stadiums[1] : Stadium(id: 'gocheok', name: '고척스카이돔', city: '서울'),
        homeTeam:
            teams.isNotEmpty
                ? teams[0]
                : Team(
                  id: '1',
                  name: '두산 베어스',
                  shortName: '두산',
                  primaryColor: Color(0xFF131230),
                  secondaryColor: Color(0xFFD4AF37),
                  logoUrl: '🐻',
                ),
        awayTeam:
            teams.length > 3
                ? teams[3]
                : Team(
                  id: '4',
                  name: '삼성 라이온즈',
                  shortName: '삼성',
                  primaryColor: Color(0xFF074CA1),
                  secondaryColor: Color(0xFFFFFFFF),
                  logoUrl: '🦁',
                ),
        homeScore: 3,
        awayScore: 3,
        result: GameResult.draw,
        seatInfo: '1루 응원석 1층',
        weather: '비',
        companions: [],
        photos: [],
        memo: '무승부로 끝났지만 좋은 경기였다.',
        isFavorite: true,
      ),
    ];
  }

  /// 오늘의 경기 데이터 (DB 기반)
  static Future<List<Map<String, dynamic>>> getTodayGames() async {
    // 실제 앱에서는 DB나 API에서 오늘의 경기 정보를 가져올 수 있음
    // 현재는 랜덤으로 경기가 있는 날과 없는 날을 결정
    final random = DateTime.now().day % 3;

    if (random == 0) {
      return []; // 경기 없음
    }

    return [
      {
        'time': '14:00',
        'stadium': '고척',
        'homeTeam': 'SSG',
        'awayTeam': '키움',
        'homeTeamLogo': '🔴',
        'awayTeamLogo': '🟣',
      },
      {
        'time': '17:00',
        'stadium': '잠실',
        'homeTeam': 'LG',
        'awayTeam': 'KIA',
        'homeTeamLogo': '⚾',
        'awayTeamLogo': '🐅',
      },
    ];
  }

  /// 뉴스 데이터
  static List<Map<String, dynamic>> getNewsItems() {
    return [
      {
        'title': "'전 NC' 하트, 5시즌 만에 빅리그...",
        'subtitle': '센디에이고 유니폼 입고 처음 첫 경기서 50일상 2실점 2024년 한국프로야구 KBO리그 투수부...',
        'image': null,
      },
      {
        'title': '"2030세대가 톡 빠졌다"...티빙, ...',
        'subtitle': '정규 시즌이 시작되기도 전에 팬들의 관심은 이미 달아올랐다. 올해 KBO 리그 시범경기 시청 UV...',
        'image': null,
      },
    ];
  }

  /// 사용자 프로필 데이터
  static Map<String, dynamic> getUserProfile() {
    return {
      'nickname': '두산승리요정',
      'avatar': '🐻',
      'greeting': '안녕하세요!',
      'teamDescription': '두산 베어스의 승요 ',
      'suffix': '님',
      'favoriteTeam': '두산 베어스',
      'joinDate': '2024년 1월',
    };
  }

  /// 홈 데이터 (DB 기반)
  static Future<Map<String, dynamic>> getHomeData() async {
    final records = await getGameRecords();
    final totalGames = records.length;
    final wins = records.where((r) => r.result == GameResult.win).length;
    final draws = records.where((r) => r.result == GameResult.draw).length;
    final losses = records.where((r) => r.result == GameResult.lose).length;

    return {
      'statsTitle': '지금까지 직관 기록은',
      'totalGamesLabel': '직관',
      'winsLabel': '승리',
      'drawsLabel': '무승부',
      'lossesLabel': '패배',
      'totalGames': totalGames,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'todayGamesTitle': '오늘의 경기는',
      'newsTitle': '최근 소식',
      'noGamesMessage': '경기가 없는 날이에요.',
      'noGamesIcon': '😴',
      'noNewsMessage': '소식이 없어요.',
      'noNewsIcon': '📰',
    };
  }
}

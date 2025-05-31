import '../models/game_record.dart';
import '../models/team.dart';
import '../models/stadium.dart';
import 'package:flutter/material.dart';

/// Mock 데이터 제공자
class MockData {
  MockData._();

  /// Mock 팀 데이터
  static final List<Team> teams = [
    Team(
      id: 'doosan',
      name: '두산 베어스',
      shortName: '두산',
      primaryColor: Color(0xFF131230),
      secondaryColor: Color(0xFFD4AF37),
      logoUrl: '🐻',
    ),
    Team(
      id: 'kia',
      name: 'KIA 타이거즈',
      shortName: 'KIA',
      primaryColor: Color(0xFFEA002C),
      secondaryColor: Color(0xFF000000),
      logoUrl: '🐅',
    ),
    Team(
      id: 'lg',
      name: 'LG 트윈스',
      shortName: 'LG',
      primaryColor: Color(0xFFC30452),
      secondaryColor: Color(0xFF000000),
      logoUrl: '⚾',
    ),
    Team(
      id: 'samsung',
      name: '삼성 라이온즈',
      shortName: '삼성',
      primaryColor: Color(0xFF074CA1),
      secondaryColor: Color(0xFFFFFFFF),
      logoUrl: '🦁',
    ),
  ];

  /// Mock 구장 데이터
  static const List<Stadium> stadiums = [
    Stadium(id: 'jamsil', name: '잠실야구장', city: '서울', capacity: 25000),
    Stadium(id: 'gocheok', name: '고척스카이돔', city: '서울', capacity: 16744),
  ];

  /// Mock 게임 기록 데이터
  static List<GameRecord> getGameRecords() {
    final now = DateTime.now();
    return [
      GameRecord(
        id: 1,
        dateTime: now.subtract(const Duration(days: 1)),
        stadium: stadiums[0],
        homeTeam: teams[0],
        awayTeam: teams[1],
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
        stadium: stadiums[0],
        homeTeam: teams[2],
        awayTeam: teams[0],
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
        stadium: stadiums[1],
        homeTeam: teams[0],
        awayTeam: teams[3],
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

  /// 오늘의 경기 데이터
  static List<Map<String, dynamic>> getTodayGames() {
    // 랜덤으로 경기가 있는 날과 없는 날을 결정
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

  /// 홈 데이터
  static Map<String, dynamic> getHomeData() {
    final records = getGameRecords();
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

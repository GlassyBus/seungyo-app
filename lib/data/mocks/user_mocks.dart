/// 사용자 프로필 Mock 데이터
class UserMocks {
  /// 현재 사용자 정보
  static Map<String, dynamic> currentUser = {
    'id': 'user12345',
    'nickname': '승요 팬',
    'favoriteTeam': 'LG 트윈스',
    'teamLogo': 'assets/emblems/twins.png',
    'level': 3,
    'registerDate': DateTime(2023, 5, 15),
    'isPremium': false,
  };

  /// 사용자 기록 통계
  static Map<String, dynamic> userStats = {
    'totalGames': 42,
    'wins': 28,
    'draws': 5,
    'losses': 9,
    'winRate': 0.66,
    'streaks': {
      'current': 3,
      'best': 7,
      'type': 'W', // W: 승리, L: 패배, D: 무승부
    },
    'lastUpdated': DateTime(2024, 4, 7),
  };

  /// 사용자 포인트 정보
  static Map<String, dynamic> userPoints = {
    'total': 2450,
    'available': 1850,
    'used': 600,
    'history': [
      {
        'date': DateTime(2024, 4, 7),
        'amount': 150,
        'type': 'earned',
        'description': '경기 예측 성공',
      },
      {
        'date': DateTime(2024, 4, 5),
        'amount': 100,
        'type': 'earned',
        'description': '로그인 보너스',
      },
      {
        'date': DateTime(2024, 4, 2),
        'amount': 300,
        'type': 'used',
        'description': '아이템 구매',
      },
    ],
  };

  /// 사용자 배지 정보
  static List<Map<String, dynamic>> userBadges = [
    {
      'id': 'badge001',
      'name': '신규 팬',
      'icon': 'assets/badges/new_fan.png',
      'description': '가입 후 첫 번째 배지',
      'dateEarned': DateTime(2023, 5, 15),
    },
    {
      'id': 'badge010',
      'name': '연승 달인',
      'icon': 'assets/badges/winning_streak.png',
      'description': '5연승 달성',
      'dateEarned': DateTime(2023, 8, 20),
    },
    {
      'id': 'badge023',
      'name': '야구 분석가',
      'icon': 'assets/badges/analyst.png',
      'description': '30회 이상 정확한 예측',
      'dateEarned': DateTime(2024, 3, 10),
    },
  ];
}

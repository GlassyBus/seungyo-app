/// Mock 데이터 설정
abstract class MockConfig {
  /// Mock 데이터 사용 여부
  static const bool useMockData = true;
  
  /// Mock 데이터 지연 시간 (밀리초)
  static const int mockDelay = 500;
  
  /// 랜덤 에러 발생 확률 (0.0 - 1.0)
  static const double errorProbability = 0.1;
  
  /// 기본 시즌 년도
  static const int defaultSeason = 2025;
  
  /// 기본 월
  static const int defaultMonth = 1;
  
  /// 월별 최대 경기 수
  static const int maxGamesPerMonth = 50;
  
  /// 기본 사용자 팀
  static const String defaultUserTeam = 'SSG';
  
  /// Mock 이미지 URL 베이스
  static const String mockImageBaseUrl = '/assets/images/mock/';
  
  /// Mock API 응답 시뮬레이션 설정
  static const Map<String, dynamic> apiSimulation = {
    'schedules': {
      'successRate': 0.9,
      'averageDelay': 800,
    },
    'records': {
      'successRate': 0.95,
      'averageDelay': 600,
    },
    'teams': {
      'successRate': 0.99,
      'averageDelay': 200,
    },
  };
}

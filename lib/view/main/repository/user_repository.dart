import '../../../data/mocks/mocks.dart';

/// 사용자 데이터 접근을 위한 Repository
class UserRepository {
  // 싱글톤 패턴 구현
  static final UserRepository _instance = UserRepository._internal();

  factory UserRepository() {
    return _instance;
  }

  UserRepository._internal();

  /// 현재 사용자 정보를 반환합니다.
  Map<String, dynamic> getCurrentUser() {
    // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옴
    // 여기서는 Mock 데이터를 사용
    return UserMocks.currentUser;
  }

  /// 사용자 닉네임을 반환합니다.
  String getUserNickname() {
    return getCurrentUser()['nickname'] ?? '익명';
  }

  /// 사용자의 선호 팀을 반환합니다.
  String getFavoriteTeam() {
    return getCurrentUser()['favoriteTeam'] ?? '';
  }

  /// 사용자의 팀 로고 이미지 경로를 반환합니다.
  String getTeamLogoImage() {
    return getCurrentUser()['teamLogo'] ?? 'assets/emblems/default.png';
  }

  /// 사용자 통계 정보를 반환합니다.
  Map<String, dynamic> getUserStats() {
    // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옴
    return UserMocks.userStats;
  }

  /// 사용자 포인트 정보를 반환합니다.
  Map<String, dynamic> getUserPoints() {
    // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옴
    return UserMocks.userPoints;
  }

  /// 사용자 배지 목록을 반환합니다.
  List<Map<String, dynamic>> getUserBadges() {
    // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옴
    return UserMocks.userBadges;
  }

  /// 사용자 레벨을 반환합니다.
  int getUserLevel() {
    return getCurrentUser()['level'] ?? 1;
  }

  /// 사용자가 프리미엄 상태인지 확인합니다.
  bool isPremiumUser() {
    return getCurrentUser()['isPremium'] ?? false;
  }
}

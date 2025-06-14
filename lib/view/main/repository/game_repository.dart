import '../models/game.dart';
import '../../../data/mocks/mocks.dart';

/// 게임 데이터 접근을 위한 Repository
///
/// 게임 정보 조회, 추가, 수정, 삭제 등의 기능을 제공합니다.
class GameRepository {
  // 싱글톤 패턴 구현
  static final GameRepository _instance = GameRepository._internal();

  factory GameRepository() {
    return _instance;
  }

  GameRepository._internal();

  /// 특정 날짜의 경기 목록을 반환합니다.
  List<Game> getGamesByDate(DateTime date) {
    // 날짜에 따라 다른 경기 데이터 반환
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    switch (dateStr) {
      case '2025.04.08':
        return GameMocks.todayGames;
      case '2025.04.07':
        // 4월 7일은 경기가 없는 날
        return [];
      case '2025.04.13':
        // 4월 13일은 경기가 있지만 우천 취소
        return []; // 비어있는 목록 반환
      default:
        return GameMocks.todayGames;
    }
  }

  /// 오늘의 경기 목록을 반환합니다.
  List<Game> getTodayGames() {
    // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옴
    // 여기서는 Mock 데이터를 사용
    return GameMocks.todayGames;
  }

  /// 오늘 경기가 취소되었는지 여부를 반환합니다.
  bool isGameDayCanceled() {
    // 오늘 날짜 기준으로 취소 여부 확인
    final today = DateTime.now();
    return isDateGameCanceled(today);
  }

  /// 특정 날짜의 경기가 취소되었는지 여부를 반환합니다.
  bool isDateGameCanceled(DateTime date) {
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    // 특정 날짜만 취소되었다고 처리 (예: 4월 13일 - 우천 취소)
    return dateStr == '2025.04.13';
  }

  /// 특정 날짜에 경기가 있는지 여부를 반환합니다.
  bool hasGamesForDate(DateTime date) {
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    // 2025.04.07은 경기가 없는 날, 2025.04.13은 우천 취소로 가정
    return dateStr != '2025.04.07';
  }

  /// 특정 팀의 경기 목록을 반환합니다.
  List<Game> getGamesByTeam(String teamName) {
    // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옴
    // 여기서는 모든 게임 중에서 해당 팀 이름이 포함된 경기만 필터링
    return getTodayGames()
        .where((game) => game.team1 == teamName || game.team2 == teamName)
        .toList();
  }

  /// 내일 예정된 경기 목록을 반환합니다.
  List<Game> getTomorrowGames() {
    // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옴
    return GameMocks.tomorrowGames;
  }

  /// 다음 주 예정된 경기 목록을 반환합니다.
  List<Game> getNextWeekGames() {
    // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옴
    return GameMocks.nextWeekGames;
  }
}

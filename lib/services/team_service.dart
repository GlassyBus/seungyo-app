import '../models/team.dart';
import '../mocks/data/mock_teams.dart';

/// 팀 관련 서비스
class TeamService {
  // 싱글톤 패턴 구현
  static final TeamService _instance = TeamService._internal();

  factory TeamService() {
    return _instance;
  }

  TeamService._internal();

  /// 모든 팀 목록 가져오기
  Future<List<Team>> getAllTeams() async {
    // 실제 앱에서는 API 호출이나 데이터베이스에서 데이터를 가져옴
    // 현재는 Mock 데이터 반환
    await Future.delayed(const Duration(milliseconds: 100)); // API 호출 시뮬레이션
    return MockTeams.teams;
  }

  /// 팀 ID로 팀 정보 가져오기
  Future<Team?> getTeamById(String teamId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return MockTeams.findById(teamId);
  }

  /// 팀 이름으로 팀 정보 가져오기
  Future<Team?> getTeamByName(String teamName) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return MockTeams.findByName(teamName);
  }

  /// 도시별 팀 목록 가져오기
  Future<List<Team>> getTeamsByCity(String city) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockTeams.getTeamsByCity(city);
  }

  /// 팀 검색
  Future<List<Team>> searchTeams(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (query.isEmpty) {
      return MockTeams.teams;
    }

    return MockTeams.teams.where((team) {
      return team.name.contains(query) ||
          team.shortName.contains(query) ||
          team.city?.contains(query) == true;
    }).toList();
  }

  /// 특정 팀들 가져오기 (ID 목록으로)
  Future<List<Team>> getTeamsByIds(List<String> teamIds) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockTeams.teams.where((team) => teamIds.contains(team.id)).toList();
  }

  /// 인기 팀 목록 가져오기 (예: 사용자가 많이 선택한 팀)
  Future<List<Team>> getPopularTeams() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // 실제 앱에서는 사용자 통계 기반으로 반환
    // 현재는 임의로 몇 개 팀 반환
    const popularTeamIds = ['lg', 'doosan', 'kia', 'samsung'];
    return MockTeams.teams
        .where((team) => popularTeamIds.contains(team.id))
        .toList();
  }

  /// 리그 통계 가져오기
  Future<Map<String, dynamic>> getLeagueStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'totalTeams': MockTeams.teams.length,
      'averageFoundedYear':
          MockTeams.teams
              .where((team) => team.foundedYear != null)
              .map((team) => team.foundedYear!)
              .reduce((a, b) => a + b) /
          MockTeams.teams.where((team) => team.foundedYear != null).length,
      'citiesWithTeams':
          MockTeams.teams
              .where((team) => team.city != null)
              .map((team) => team.city!)
              .toSet()
              .length,
    };
  }
}

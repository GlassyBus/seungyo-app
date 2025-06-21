import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../services/database_service.dart';

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
    try {
      return await DatabaseService().getTeamsAsAppModels();
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('Error getting teams from DB: $e');
      return [];
    }
  }

  /// 팀 ID로 팀 정보 가져오기
  Future<Team?> getTeamById(String teamId) async {
    try {
      final teams = await getAllTeams();
      return teams.where((team) => team.id == teamId).firstOrNull;
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('Error getting team by ID: $e');
      return null;
    }
  }

  /// 팀 이름으로 팀 정보 가져오기
  Future<Team?> getTeamByName(String teamName) async {
    try {
      final teams = await getAllTeams();
      return teams
          .where((team) => team.name == teamName || team.shortName == teamName)
          .firstOrNull;
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('Error getting team by name: $e');
      return null;
    }
  }

  /// 도시별 팀 목록 가져오기 (현재 DB에는 city 정보가 없으므로 빈 리스트 반환)
  Future<List<Team>> getTeamsByCity(String city) async {
    // DB의 Teams 테이블에는 city 정보가 없으므로 빈 리스트 반환
    return [];
  }

  /// 팀 검색
  Future<List<Team>> searchTeams(String query) async {
    try {
      final teams = await getAllTeams();

      if (query.isEmpty) {
        return teams;
      }

      return teams.where((team) {
        return team.name.contains(query) || team.shortName.contains(query);
      }).toList();
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('Error searching teams: $e');
      return [];
    }
  }

  /// 특정 팀들 가져오기 (ID 목록으로)
  Future<List<Team>> getTeamsByIds(List<String> teamIds) async {
    try {
      final teams = await getAllTeams();
      return teams.where((team) => teamIds.contains(team.id)).toList();
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('Error getting teams by IDs: $e');
      return [];
    }
  }

  /// 인기 팀 목록 가져오기 (예: 사용자가 많이 선택한 팀)
  Future<List<Team>> getPopularTeams() async {
    try {
      final teams = await getAllTeams();
      // 실제 앱에서는 사용자 통계 기반으로 반환
      // 현재는 처음 4개 팀 반환
      return teams.take(4).toList();
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('Error getting popular teams: $e');
      return [];
    }
  }

  /// 리그 통계 가져오기
  Future<Map<String, dynamic>> getLeagueStats() async {
    try {
      final teams = await getAllTeams();
      return {
        'totalTeams': teams.length,
        'averageFoundedYear': 1985, // 기본값
        'citiesWithTeams': 9, // KBO 9개 도시
      };
    } catch (e) {
      if (kDebugMode) if (kDebugMode) print('Error getting league stats: $e');
      return {'totalTeams': 0, 'averageFoundedYear': 0, 'citiesWithTeams': 0};
    }
  }
}

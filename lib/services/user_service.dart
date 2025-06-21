import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/team.dart' as app_models;
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../repository/shared_preferences_helper.dart';
import '../repository/auth_repository.dart';
import '../constants/team_data.dart';

class UserService {
  static const String _profileKey = 'user_profile';
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();

  // 싱글톤 패턴 구현
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  // 기본 사용자 프로필
  UserProfile get _defaultProfile => UserProfile(
    nickname: '두산승리요정',
    favoriteTeamId: 'bears', // String ID로 변경
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // 사용자 프로필 가져오기 (AuthRepository에서 데이터 읽기)
  Future<UserProfile> getUserProfile() async {
    try {
      print('UserService: Getting user profile...');
      
      // AuthRepository에서 닉네임과 팀 코드 가져오기
      final authRepo = AuthRepository();
      final nickname = await authRepo.getNickname();
      final teamCode = await authRepo.getTeam();
      
      print('UserService: Nickname from AuthRepository: $nickname');
      print('UserService: Team code from AuthRepository: $teamCode');

      if (nickname != null && teamCode != null) {
        // AuthRepository에서 데이터를 찾았다면 팀 코드를 통해 팀 ID 찾기
        final teamData = TeamData.getByCode(teamCode);
        final teamId = teamData?.id ?? 'bears'; // 기본값
        
        final profile = UserProfile(
          nickname: nickname,
          favoriteTeamId: teamId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        print('UserService: Created profile from AuthRepository - Nickname: ${profile.nickname}, TeamId: ${profile.favoriteTeamId}');
        return profile;
      }

      // SharedPreferencesHelper에서 닉네임과 팀 ID 가져오기 (fallback)
      final prefsNickname = await _prefsHelper.getNickname();
      final prefsTeamId = await _prefsHelper.getSelectedTeamId();
      
      print('UserService: Fallback - Nickname from prefs: $prefsNickname');
      print('UserService: Fallback - Team ID from prefs: $prefsTeamId');

      if (prefsNickname != null && prefsTeamId != null) {
        final profile = UserProfile(
          nickname: prefsNickname,
          favoriteTeamId: prefsTeamId.toString(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        print('UserService: Created profile from SharedPreferencesHelper - Nickname: ${profile.nickname}, TeamId: ${profile.favoriteTeamId}');
        return profile;
      }

      // SharedPreferences에서 기존 방식으로 저장된 프로필 확인
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);

      if (profileJson == null) {
        // 프로필이 없으면 기본 프로필 생성 후 저장
        print('UserService: No profile found, using default profile');
        await saveUserProfile(_defaultProfile);
        return _defaultProfile;
      }

      final json = jsonDecode(profileJson);
      return UserProfile.fromJson(json);
    } catch (e) {
      print('Error getting user profile: $e');
      return _defaultProfile;
    }
  }

  // 사용자 프로필 저장 (AuthRepository와 동기화)
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      print('UserService: Saving user profile...');
      
      // AuthRepository에 닉네임과 팀 코드 저장
      final authRepo = AuthRepository();
      await authRepo.setNickname(profile.nickname);
      
      // favoriteTeamId로 팀 코드 찾아서 저장
      final teamData = TeamData.getById(profile.favoriteTeamId);
      if (teamData != null) {
        await authRepo.setTeam(teamData.code);
        print('UserService: Saved to AuthRepository - Nickname: ${profile.nickname}, TeamCode: ${teamData.code}');
      }

      // SharedPreferencesHelper에도 저장 (호환성 유지)
      await _prefsHelper.setNickname(profile.nickname);
      final teamIdInt = int.tryParse(profile.favoriteTeamId);
      if (teamIdInt != null) {
        await _prefsHelper.setSelectedTeamId(teamIdInt);
      }

      // 기존 방식으로도 저장 (호환성 유지)
      final prefs = await SharedPreferences.getInstance();
      final json = profile.toJson();
      final jsonString = jsonEncode(json);

      final success = await prefs.setString(_profileKey, jsonString);

      if (!success) {
        throw Exception('SharedPreferences 저장 실패');
      }
      
      print('UserService: Profile saved successfully');
    } catch (e, stackTrace) {
      print('Error saving user profile: $e');
      throw Exception('프로필 저장 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 닉네임 업데이트
  Future<UserProfile> updateNickname(String nickname) async {
    try {
      final currentProfile = await getUserProfile();

      final updatedProfile = currentProfile.copyWith(nickname: nickname, updatedAt: DateTime.now());

      await saveUserProfile(updatedProfile);
      return updatedProfile;
    } catch (e, stackTrace) {
      print('Error updating nickname: $e');
      throw Exception('닉네임 업데이트 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 응원 팀 업데이트
  Future<UserProfile> updateFavoriteTeam(String teamId) async {
    try {
      final currentProfile = await getUserProfile();
      final updatedProfile = currentProfile.copyWith(favoriteTeamId: teamId, updatedAt: DateTime.now());
      await saveUserProfile(updatedProfile);
      return updatedProfile;
    } catch (e, stackTrace) {
      print('Error updating favorite team: $e');
      throw Exception('응원 팀 업데이트 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 사용자의 응원 팀 정보 가져오기 (DB에서 실제 팀 정보 조회)
  Future<app_models.Team?> getUserFavoriteTeam() async {
    try {
      print('UserService: Getting user favorite team...');
      
      final profile = await getUserProfile();
      print('UserService: User favorite team ID from profile: ${profile.favoriteTeamId}');

      final teams = await DatabaseService().getTeamsAsAppModels();
      print('UserService: Found ${teams.length} teams in database');

      // 프로필의 favoriteTeamId로 팀 찾기
      final favoriteTeam = teams.where((team) => team.id == profile.favoriteTeamId).firstOrNull;

      if (favoriteTeam != null) {
        print('UserService: Found favorite team: ${favoriteTeam.name} (ID: ${favoriteTeam.id})');
        return favoriteTeam;
      } else {
        print('UserService: Favorite team not found, using first available team');
        // 팀을 찾지 못한 경우 첫 번째 팀을 반환
        final fallbackTeam = teams.isNotEmpty ? teams.first : null;
        if (fallbackTeam != null) {
          print('UserService: Using fallback team: ${fallbackTeam.name}');
        }
        return fallbackTeam;
      }
    } catch (e) {
      print('Error getting user favorite team: $e');
      return null;
    }
  }

  // 사용자 프로필 초기화 (테스트용)
  Future<void> resetUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
      print('UserService: User profile reset');
    } catch (e) {
      print('Error resetting user profile: $e');
    }
  }
}

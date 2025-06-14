import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/team.dart';
import '../services/database_service.dart';

class UserService {
  static const String _profileKey = 'user_profile';

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

  // 사용자 프로필 가져오기
  Future<UserProfile> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);

      if (profileJson == null) {
        // 프로필이 없으면 기본 프로필 생성 후 저장
        await saveUserProfile(_defaultProfile);
        return _defaultProfile;
      }

      final json = jsonDecode(profileJson);
      return UserProfile.fromJson(json);
    } catch (e) {
      return _defaultProfile;
    }
  }

  // 사용자 프로필 저장
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = profile.toJson();
      final jsonString = jsonEncode(json);

      final success = await prefs.setString(_profileKey, jsonString);

      if (!success) {
        throw Exception('SharedPreferences 저장 실패');
      }
    } catch (e, stackTrace) {
      throw Exception('프로필 저장 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 닉네임 업데이트
  Future<UserProfile> updateNickname(String nickname) async {
    try {
      final currentProfile = await getUserProfile();

      final updatedProfile = currentProfile.copyWith(
        nickname: nickname,
        updatedAt: DateTime.now(),
      );

      await saveUserProfile(updatedProfile);
      return updatedProfile;
    } catch (e, stackTrace) {
      throw Exception('닉네임 업데이트 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 응원 팀 업데이트
  Future<UserProfile> updateFavoriteTeam(String teamId) async {
    try {
      final currentProfile = await getUserProfile();
      final updatedProfile = currentProfile.copyWith(
        favoriteTeamId: teamId,
        updatedAt: DateTime.now(),
      );
      await saveUserProfile(updatedProfile);
      return updatedProfile;
    } catch (e, stackTrace) {
      throw Exception('응원 팀 업데이트 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 사용자의 응원 팀 정보 가져오기
  Future<Team?> getUserFavoriteTeam() async {
    try {
      final profile = await getUserProfile();
      final teams = await DatabaseService().getTeamsAsAppModels();
      return teams.where((team) => team.id == profile.favoriteTeamId).firstOrNull;
    } catch (e) {
      print('Error getting user favorite team: $e');
      return null;
    }
  }

  // 로컬 파일 경로 가져오기
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}

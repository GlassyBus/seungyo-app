import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user_profile.dart';
import '../models/team.dart';
import '../mocks/data/mock_teams.dart';

class UserService {
  static const String _fileName = 'user_profile.json';

  // 싱글톤 패턴 구현
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  // 기본 사용자 프로필
  UserProfile get _defaultProfile => UserProfile(
    nickname: '두산승리요정',
    favoriteTeamId: 'doosan',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // 사용자 프로필 가져오기
  Future<UserProfile> getUserProfile() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        // 파일이 없으면 기본 프로필 생성 후 저장
        await saveUserProfile(_defaultProfile);
        return _defaultProfile;
      }

      final contents = await file.readAsString();
      final json = jsonDecode(contents);
      return UserProfile.fromJson(json);
    } catch (e) {
      print('Error loading user profile: $e');
      return _defaultProfile;
    }
  }

  // 사용자 프로필 저장
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final file = await _getLocalFile();
      final json = profile.toJson();
      await file.writeAsString(jsonEncode(json));
    } catch (e) {
      print('Error saving user profile: $e');
      throw Exception('프로필 저장 중 오류가 발생했습니다');
    }
  }

  // 닉네임 업데이트
  Future<UserProfile> updateNickname(String nickname) async {
    final currentProfile = await getUserProfile();
    final updatedProfile = currentProfile.copyWith(
      nickname: nickname,
      updatedAt: DateTime.now(),
    );
    await saveUserProfile(updatedProfile);
    return updatedProfile;
  }

  // 응원 팀 업데이트
  Future<UserProfile> updateFavoriteTeam(String teamId) async {
    final currentProfile = await getUserProfile();
    final updatedProfile = currentProfile.copyWith(
      favoriteTeamId: teamId,
      updatedAt: DateTime.now(),
    );
    await saveUserProfile(updatedProfile);
    return updatedProfile;
  }

  // 사용자의 응원 팀 정보 가져오기
  Future<Team?> getUserFavoriteTeam() async {
    final profile = await getUserProfile();
    return MockTeams.findById(profile.favoriteTeamId);
  }

  // 로컬 파일 경로 가져오기
  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}

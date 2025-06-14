import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  // Keys
  static const String _keySelectedTeamId = 'selected_team_id';
  static const String _keyNickname = 'nickname';
  static const String _keyIsLoggedIn = 'is_logged_in';

  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // 사용자 관련 메서드들
  Future<int?> getSelectedTeamId() async {
    return await getInt(_keySelectedTeamId);
  }

  Future<void> setSelectedTeamId(int teamId) async {
    await setInt(_keySelectedTeamId, teamId);
  }

  Future<String?> getNickname() async {
    return await getString(_keyNickname);
  }

  Future<void> setNickname(String nickname) async {
    await setString(_keyNickname, nickname);
  }

  Future<bool> getIsLoggedIn() async {
    return await getBool(_keyIsLoggedIn) ?? false;
  }

  Future<void> setIsLoggedIn(bool isLoggedIn) async {
    await setBool(_keyIsLoggedIn, isLoggedIn);
  }

  // 로그아웃 (모든 사용자 데이터 삭제)
  Future<void> logout() async {
    await remove(_keySelectedTeamId);
    await remove(_keyNickname);
    await setIsLoggedIn(false);
  }
}

import 'package:seungyo/constants/constants.dart';
import 'package:seungyo/repository/shared_preferences_helper.dart';

class AuthRepository {
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();

  Future<bool> isLoggedIn() async {
    return await _prefsHelper.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefsHelper.setBool(AppConstants.isLoggedInKey, value);
    if (value) {
      await _prefsHelper.setBool(AppConstants.hasPreviousLoginKey, true);
    }
  }

  Future<void> logout() async {
    await _prefsHelper.setBool(AppConstants.isLoggedInKey, false);
  }

  Future<void> setNickname(String nickname) async {
    await _prefsHelper.setString(AppConstants.nicknameKey, nickname);
  }

  Future<void> setTeam(String team) async {
    await _prefsHelper.setString(AppConstants.selectedTeamKey, team);
  }

  Future<String?> getNickname() async {
    return await _prefsHelper.getString(AppConstants.nicknameKey);
  }

  Future<String?> getTeam() async {
    return await _prefsHelper.getString(AppConstants.selectedTeamKey);
  }
}

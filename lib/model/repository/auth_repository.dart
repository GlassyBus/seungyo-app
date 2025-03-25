import 'package:seungyo/constants.dart';

import '../data/shared_preferences_helper.dart';

class AuthRepository {
  final SharedPreferencesHelper _prefsHelper = SharedPreferencesHelper();

  Future<bool> isLoggedIn() async {
    return await _prefsHelper.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  Future<bool> hasPreviousLogin() async {
    return await _prefsHelper.getBool(AppConstants.hasPreviousLoginKey) ?? false;
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
}

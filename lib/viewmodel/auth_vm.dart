import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthViewModel extends ChangeNotifier {
  String? _team;
  String? _nickname;
  DateTime? _lastBackPressTime;

  String? get team => _team;
  String? get nickname => _nickname;

  Future<void> selectTeam(String team) async {
    _team = team;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_team', team);
    notifyListeners();
  }

  Future<void> enterNickname(String nickname) async {
    _nickname = nickname;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);
    await prefs.setBool('isLoggedIn', true);
    notifyListeners();
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    _team = prefs.getString('selected_team');
    _nickname = prefs.getString('nickname');
    notifyListeners();
  }

  Future<bool> handleDoubleBackPress(BuildContext context) async {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      Fluttertoast.showToast(msg: '뒤로 버튼을 한 번 더 누르면 앱이 종료됩니다');
      return false;
    }
    return true;
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:seungyo/repository/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  String? _team;
  String? _nickname;
  DateTime? _lastBackPressTime;

  String? get team => _team;

  String? get nickname => _nickname;

  void selectTeam(String? team) {
    _team = team;
    notifyListeners();
  }

  void setNickname(String nickname) {
    _nickname = nickname;
    notifyListeners();
  }

  Future<void> saveUserInfo() async {
    if (_team != null) await _authRepo.setTeam(_team!);
    if (_nickname != null) await _authRepo.setNickname(_nickname!);
    await _authRepo.setLoggedIn(true);
  }

  Future<void> loadSavedData() async {
    _team = await _authRepo.getTeam();
    _nickname = await _authRepo.getNickname();
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

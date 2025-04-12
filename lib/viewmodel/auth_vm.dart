import 'package:flutter/material.dart';
import '../model/repository/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  Future<void> login() async {
    // 로그인 처리 후 로그인 상태 업데이트
    await _authRepository.setLoggedIn(true);
    notifyListeners();
  }

  Future<void> signup(String nickname) async {
    // 회원가입 처리 (닉네임 및 기타 정보 저장 처리 추후 Moor 연동)
    await _authRepository.setLoggedIn(true);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    notifyListeners();
  }
}

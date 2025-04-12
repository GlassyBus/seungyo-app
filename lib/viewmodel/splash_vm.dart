import 'package:flutter/material.dart';
import 'package:seungyo/routes.dart';

import '../model/repository/auth_repository.dart';

class SplashViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  Future<void> checkLoginStatus(BuildContext context) async {
    await Future.delayed(Duration(seconds: 2));
    bool isLoggedIn = await _authRepository.isLoggedIn();

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, Routes.main);
    } else {
      bool hasPreviousLogin = await _authRepository.hasPreviousLogin();
      if (hasPreviousLogin) {
        Navigator.pushReplacementNamed(context, Routes.login);
      } else {
        Navigator.pushReplacementNamed(context, Routes.signup);
      }
    }
  }
}

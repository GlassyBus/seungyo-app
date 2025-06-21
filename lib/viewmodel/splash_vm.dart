import 'package:flutter/material.dart';
import 'package:seungyo/repository/auth_repository.dart';
import 'package:seungyo/routes.dart';

class SplashViewModel {
  final AuthRepository _authRepository = AuthRepository();

  Future<void> checkAuthStatus(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = await _authRepository.isLoggedIn();

    if (context.mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, Routes.main);
      } else {
        Navigator.pushReplacementNamed(context, Routes.auth);
      }
    }
  }
}

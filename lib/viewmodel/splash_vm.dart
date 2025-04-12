import 'package:flutter/material.dart';
import 'package:seungyo/repository/auth_repository.dart';
import 'package:seungyo/routes.dart';

class SplashViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  Future<void> handleNavigation(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final isLoggedIn = await _authRepository.isLoggedIn();

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, Routes.main);
    } else {
      Navigator.pushReplacementNamed(context, Routes.auth);
    }
  }
}

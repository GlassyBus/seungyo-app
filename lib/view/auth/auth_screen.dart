import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/routes.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';

import 'widgets/nickname_input_view.dart';
import 'widgets/select_team_view.dart';
import 'widgets/welcome_view.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, Routes.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel()..loadSavedData(),
      child: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: PageView(
                key: ValueKey(_currentPage),
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  SelectTeamView(onNext: _nextPage),
                  NicknameInputView(onNext: _nextPage),
                  WelcomeView(onNext: _nextPage),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

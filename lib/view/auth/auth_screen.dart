import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;

              if (_currentPage == 0) {
                final shouldExit = await vm.handleDoubleBackPress(context);
                if (shouldExit) {
                  SystemNavigator.pop();
                }
              }
            },
            child: Scaffold(
              body: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  SelectTeamView(onNext: _nextPage),
                  NicknameInputView(onNext: _nextPage, onBack: _previousPage),
                  WelcomeView(
                    onNext:
                        () => Navigator.pushReplacementNamed(
                          context,
                          Routes.main,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/model/team_data.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';
import 'package:seungyo/widgets/app_title_bar.dart';

class WelcomeView extends StatefulWidget {
  final VoidCallback onNext;

  const WelcomeView({super.key, required this.onNext});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  Future<void> _startCountdown() async {
    while (_countdown > 1) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _countdown--);
    }
    await Future.delayed(const Duration(seconds: 1));
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final team = vm.team ?? '구단';
    final nickname = vm.nickname ?? '승요';
    final teamInfo = TeamData.getByName(team);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: const AppTitleBar(
          center: Text(
            '회원가입 완료',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 128),
                  // 엠블럼 생략
                  const SizedBox(height: 16),
                  Text(
                    '$team 승요\n$nickname님!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 35),
                  const Text(
                    '승리의 기록을\n남기러 가볼까요?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    '$_countdown',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

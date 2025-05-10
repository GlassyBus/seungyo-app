import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/constants/team_data.dart';
import 'package:seungyo/theme/app_colors.dart';
import 'package:seungyo/theme/app_text_styles.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';

class WelcomeView extends StatefulWidget {
  final VoidCallback onNext;

  const WelcomeView({super.key, required this.onNext});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  int _countdown = 4;

  @override
  void initState() {
    super.initState();
    context.read<AuthViewModel>().loadSavedData();
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
    final teamCode = vm.team ?? 'bears';
    final teamName = vm.teamName ?? 'LG 트윈스';
    final nickname = vm.nickname ?? 'LG승리요정';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('회원가입 완료', style: AppTextStyles.subtitle1),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.black,
          elevation: 0,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 메인 콘텐츠 영역
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 팀 로고 및 정보
                      Column(
                        children: [
                          // 팀 로고
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.navy5,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gray30, width: 1),
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Image.asset(TeamData.getByCode(teamCode)?.emblem ?? '', fit: BoxFit.contain),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 팀 이름
                          Text(
                            '$teamName 승요의',
                            style: AppTextStyles.subtitle1.copyWith(color: AppColors.navy),
                            textAlign: TextAlign.center,
                          ),

                          // 닉네임 표시 (하이라이트 효과 적용)
                          const SizedBox(height: 3),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 닉네임 (글로우 효과)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(color: AppColors.mint.withOpacity(0.3), blurRadius: 10, spreadRadius: 1),
                                  ],
                                ),
                                child: Text(
                                  nickname,
                                  style: AppTextStyles.h3.copyWith(color: AppColors.navy, fontWeight: FontWeight.bold),
                                ),
                              ),
                              // '님!' 텍스트
                              Text(
                                '님!',
                                style: AppTextStyles.h3.copyWith(color: AppColors.navy, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 35),

                      // "승리의 기록을 남기러 가볼까요?" 텍스트
                      Text(
                        '승리의 기록을\n남기러 가볼까요?',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h1.copyWith(color: AppColors.navy),
                      ),

                      // 카운트다운 표시
                      const SizedBox(height: 20),
                      Text(
                        '${_countdown - 1}초 후 자동으로 이동합니다',
                        style: AppTextStyles.body2.copyWith(color: AppColors.gray70),
                      ),
                    ],
                  ),
                ),
              ),

              // 하단 홈 인디케이터
              Container(
                width: 134,
                height: 5,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

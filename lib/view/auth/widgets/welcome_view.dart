import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';import 'package:provider/provider.dart';
import 'package:seungyo/models/team.dart' as app_models;
import 'package:seungyo/services/database_service.dart';
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

  // 팀 데이터 관련
  List<app_models.Team> _teams = [];
  app_models.Team? _selectedTeam;
  bool _isLoadingTeams = true;

  @override
  void initState() {
    super.initState();
    context.read<AuthViewModel>().loadSavedData();
    _loadTeams();
    _startCountdown();
  }

  Future<void> _loadTeams() async {
    try {
      if (kDebugMode) print('WelcomeView: Loading teams from database...');
      final teams = await DatabaseService().getTeamsAsAppModels();
      if (kDebugMode) print('WelcomeView: Loaded ${teams.length} teams');

      setState(() {
        _teams = teams;
        _isLoadingTeams = false;
      });

      // 선택된 팀 찾기
      final vm = context.read<AuthViewModel>();
      if (kDebugMode) print('WelcomeView: AuthViewModel team value: "${vm.team}"');

      if (vm.team != null && _teams.isNotEmpty) {
        final selectedTeam = _teams.where((team) => team.id == vm.team).firstOrNull;

        setState(() {
          _selectedTeam = selectedTeam;
        });

        if (selectedTeam != null) {
          if (kDebugMode) print('WelcomeView: ✅ Found team: ${selectedTeam.name} (Logo: ${selectedTeam.logo})');
        } else {
          if (kDebugMode) print('WelcomeView: ❌ No team found for ID: ${vm.team}');
          // 팀을 찾지 못한 경우 첫 번째 팀을 fallback으로 사용
          if (_teams.isNotEmpty) {
            setState(() {
              _selectedTeam = _teams.first;
            });
            if (kDebugMode) print('WelcomeView: Using fallback team: ${_teams.first.name}');
          }
        }
      } else {
        if (kDebugMode) print('WelcomeView: vm.team is null or teams list is empty');
      }
    } catch (e) {
      if (kDebugMode) print('WelcomeView: Error loading teams: $e');
      setState(() {
        _isLoadingTeams = false;
      });
    }
  }

  Future<void> _startCountdown() async {
    while (_countdown > 1) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _countdown--);
      }
    }
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final teamName = _selectedTeam?.name ?? 'LG 트윈스';
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
                child: SizedBox(
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
                              child: Padding(padding: const EdgeInsets.all(20.0), child: _buildTeamLogo()),
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
                                    BoxShadow(color: AppColors.mint.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamLogo() {
    if (kDebugMode) print('WelcomeView: _buildTeamLogo called');
    if (kDebugMode) print('WelcomeView: _isLoadingTeams: $_isLoadingTeams');
    if (kDebugMode) print('WelcomeView: _selectedTeam: $_selectedTeam');

    if (_isLoadingTeams) {
      if (kDebugMode) print('WelcomeView: Still loading teams, showing spinner');
      return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.navy));
    }

    if (_selectedTeam != null) {
      if (kDebugMode) print('WelcomeView: Selected team found: ${_selectedTeam!.name}');
      if (kDebugMode) print('WelcomeView: Team logo: ${_selectedTeam!.logo}');
      if (kDebugMode) print('WelcomeView: Team shortName: ${_selectedTeam!.shortName}');

      if (_selectedTeam!.logo != null && _selectedTeam!.logo!.isNotEmpty) {
        if (_selectedTeam!.logo!.startsWith('assets/')) {
          if (kDebugMode) print('WelcomeView: Loading asset image: ${_selectedTeam!.logo}');
          return Image.asset(
            _selectedTeam!.logo!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              if (kDebugMode) print('WelcomeView: Error loading asset image: $error');
              return _buildFallbackLogo();
            },
          );
        } else {
          // 이모지나 다른 텍스트
          if (kDebugMode) print('WelcomeView: Using emoji/text logo: ${_selectedTeam!.logo}');
          return Center(child: Text(_selectedTeam!.logo!, style: const TextStyle(fontSize: 40)));
        }
      } else {
        if (kDebugMode) print('WelcomeView: Logo is empty, using fallback');
        return _buildFallbackLogo();
      }
    } else {
      // 팀을 찾을 수 없는 경우 기본 아이콘
      if (kDebugMode) print('WelcomeView: No selected team, showing default icon');
      return const Center(child: Icon(Icons.sports_baseball, size: 40, color: AppColors.navy));
    }
  }

  Widget _buildFallbackLogo() {
    if (kDebugMode) print('WelcomeView: _buildFallbackLogo called');
    if (_selectedTeam != null && _selectedTeam!.shortName.isNotEmpty) {
      final firstChar = _selectedTeam!.shortName.substring(0, 1);
      if (kDebugMode) print('WelcomeView: Using first character of shortName: $firstChar');
      return Center(
        child: Text(
          firstChar,
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
      );
    } else {
      if (kDebugMode) print('WelcomeView: Using baseball emoji as fallback');
      return const Center(
        child: Text('⚾', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.navy)),
      );
    }
  }
}

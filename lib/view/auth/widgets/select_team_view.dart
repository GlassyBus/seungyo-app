import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';import 'package:provider/provider.dart';
import 'package:seungyo/models/team.dart' as app_models;
import 'package:seungyo/services/database_service.dart';
import 'package:seungyo/theme/theme.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';

class SelectTeamView extends StatefulWidget {
  /// 다음 단계로 진행하는 콜백
  final VoidCallback? onNext;

  /// 독립적인 팀 선택 화면인지 여부 (프로필 수정용)
  final bool isStandalone;

  /// 현재 선택된 팀 ID (프로필 수정 시)
  final String? currentTeamId;

  /// 앱바 제목
  final String? title;

  const SelectTeamView({
    super.key,
    this.onNext,
    this.isStandalone = false,
    this.currentTeamId,
    this.title,
  });

  @override
  State<SelectTeamView> createState() => _SelectTeamViewState();
}

class _SelectTeamViewState extends State<SelectTeamView> {
  List<app_models.Team> _teams = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    _selectedTeamId = widget.currentTeamId;
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (kDebugMode) print('SelectTeamView: Loading teams from database...');
      _teams = await DatabaseService().getTeamsAsAppModels();
      if (kDebugMode) print('SelectTeamView: Loaded ${_teams.length} teams');

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) print('SelectTeamView: Error loading teams: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isStandalone) {
      return _buildStandaloneScreen();
    } else {
      return _buildAuthFlowScreen();
    }
  }

  Widget _buildStandaloneScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title ?? '응원 구단 변경', style: AppTextStyles.subtitle1),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 25),
                    Text(
                      '어느 구단을 응원하시나요?',
                      style: AppTextStyles.h3.copyWith(color: AppColors.navy),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _buildContent(),
                  ],
                ),
              ),
            ),
          ),
          _buildStandaloneBottomButton(),
        ],
      ),
    );
  }

  Widget _buildAuthFlowScreen() {
    final vm = context.watch<AuthViewModel>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('정보 입력', style: AppTextStyles.subtitle1),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.black,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 25),
                        Text(
                          '어느 구단을 응원하시나요?',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.navy,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        _buildContent(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildAuthFlowBottomButton(vm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: CircularProgressIndicator(color: AppColors.navy),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          children: [
            Text(
              _errorMessage!,
              style: AppTextStyles.body2.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTeams,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return _buildTeamGrid();
  }

  Widget _buildTeamGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      itemCount: _teams.length,
      itemBuilder: (context, index) {
        final team = _teams[index];
        final isSelected =
            widget.isStandalone
                ? (_selectedTeamId == team.id)
                : (context.watch<AuthViewModel>().team == team.id);

        return GestureDetector(
          onTap: () {
            if (kDebugMode) print('SelectTeamView: Team selected - ${team.name} (${team.id})');
            if (widget.isStandalone) {
              setState(() {
                _selectedTeamId = team.id;
              });
            } else {
              final vm = context.read<AuthViewModel>();
              vm.selectTeam(isSelected ? null : team.id);
            }
          },
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.mint : AppColors.gray10,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.mint : AppColors.gray20,
                    width: isSelected ? 3 : 2,
                  ),
                ),
                child: Center(
                  child:
                      team.logo != null && team.logo!.isNotEmpty
                          ? team.logo!.startsWith('assets/')
                              ? Image.asset(
                                team.logo!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text(
                                    team.shortName.substring(0, 1),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              )
                              : Text(
                                team.logo!,
                                style: const TextStyle(fontSize: 32),
                              )
                          : Text(
                            team.shortName.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                team.name,
                style: AppTextStyles.body2.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.navy : AppColors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuthFlowBottomButton(AuthViewModel vm) {
    final selectedTeam =
        vm.team != null
            ? _teams.where((team) => team.id == vm.team).firstOrNull
            : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed:
                  selectedTeam != null && !_isLoading && widget.onNext != null
                      ? widget.onNext
                      : null,
              style: TextButton.styleFrom(
                backgroundColor:
                    selectedTeam != null ? AppColors.navy : AppColors.navy5,
                foregroundColor:
                    selectedTeam != null ? Colors.white : AppColors.navy30,
                disabledForegroundColor: AppColors.navy30,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text('다음', style: AppTextStyles.subtitle2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandaloneBottomButton() {
    final selectedTeam =
        _selectedTeamId != null
            ? _teams.where((team) => team.id == _selectedTeamId).firstOrNull
            : null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed:
              selectedTeam != null && !_isLoading
                  ? () {
                    if (kDebugMode) print(
                      'SelectTeamView: Returning selected team - ${selectedTeam.name}',
                    );
                    Navigator.pop(context, selectedTeam);
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.gray30,
            disabledForegroundColor: AppColors.gray50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(
                    '선택 완료',
                    style: AppTextStyles.subtitle2.copyWith(
                      color:
                          selectedTeam != null
                              ? Colors.white
                              : AppColors.gray50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }
}

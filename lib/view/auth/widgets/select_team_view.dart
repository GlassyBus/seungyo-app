import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/constants/team_data.dart';
import 'package:seungyo/theme/app_colors.dart';
import 'package:seungyo/theme/app_text_styles.dart';
import 'package:seungyo/view/auth/widgets/components/team_button.dart';
import 'package:seungyo/viewmodel/auth_vm.dart';

/// 팀 선택 화면 위젯
///
/// 사용자가 응원하는 팀을 선택하는 화면을 표시합니다.
/// [onNext]는 다음 단계로 진행하는 콜백입니다.
class SelectTeamView extends StatefulWidget {
  /// 다음 단계로 진행하는 콜백
  final VoidCallback onNext;

  const SelectTeamView({super.key, required this.onNext});

  @override
  State<SelectTeamView> createState() => _SelectTeamViewState();
}

class _SelectTeamViewState extends State<SelectTeamView> {
  /// 레이아웃 상수
  static const double _horizontalPadding = 16.0; // 패딩 줄임
  static const double _gridSpacing = 12.0; // 간격 줄임
  static const double _gridRowSpacing = 14.0; // 행 간격 늘림

  /// 고정된 그리드 컬럼 수
  static const int _columnCount = 3;

  @override
  Widget build(BuildContext context) {
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
              // 스크롤 가능한 콘텐츠 영역
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 25),
                        // 타이틀
                        Text(
                          '어느 구단을 응원하시나요?',
                          style: AppTextStyles.h3.copyWith(color: AppColors.navy),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        // 팀 선택 그리드
                        _buildTeamGrid(vm),
                      ],
                    ),
                  ),
                ),
              ),

              // 하단 버튼 영역
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    // 다음 버튼
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: TextButton(
                        onPressed: vm.team != null ? widget.onNext : null,
                        style: TextButton.styleFrom(
                          backgroundColor: vm.team != null ? AppColors.navy : AppColors.navy5,
                          foregroundColor: vm.team != null ? Colors.white : AppColors.navy30,
                          disabledForegroundColor: AppColors.navy30,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text('다음', style: AppTextStyles.subtitle2),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // iOS 홈 인디케이터
                    Container(
                      width: 134,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 팀 선택 그리드 위젯
  Widget _buildTeamGrid(AuthViewModel vm) {
    return Padding(
      key: const Key('team_selection_grid'),
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // 첫 번째 행 (KIA, KT, LG)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTeamButtonWithWidth(vm, 'tigers', 0),
              SizedBox(width: _gridSpacing),
              _buildTeamButtonWithWidth(vm, 'wiz', 1),
              SizedBox(width: _gridSpacing),
              _buildTeamButtonWithWidth(vm, 'twins', 2),
            ],
          ),
          // 첫 번째 행과 두 번째 행 사이 간격 조정
          SizedBox(height: _gridRowSpacing + 4),

          // 두 번째 행 (NC, SSG, 두산)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTeamButtonWithWidth(vm, 'dinos', 3),
              SizedBox(width: _gridSpacing),
              _buildTeamButtonWithWidth(vm, 'landers', 4),
              SizedBox(width: _gridSpacing),
              _buildTeamButtonWithWidth(vm, 'bears', 5),
            ],
          ),
          // 첫 번째 행과 두 번째 행 사이 간격 조정
          SizedBox(height: _gridRowSpacing + 4),

          // 세 번째 행 (롯데, 삼성, 키움)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTeamButtonWithWidth(vm, 'giants', 6),
              SizedBox(width: _gridSpacing),
              _buildTeamButtonWithWidth(vm, 'lions', 7),
              SizedBox(width: _gridSpacing),
              _buildTeamButtonWithWidth(vm, 'heroes', 8),
            ],
          ),
          // 첫 번째 행과 두 번째 행 사이 간격 조정
          SizedBox(height: _gridRowSpacing + 4),

          // 네 번째 행 (한화)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTeamButtonWithWidth(vm, 'eagles', 9),
              SizedBox(width: _gridSpacing),
              // 빈 공간 유지
              Opacity(opacity: 0, child: _buildEmptySpace()),
              SizedBox(width: _gridSpacing),
              // 빈 공간 유지
              Opacity(opacity: 0, child: _buildEmptySpace()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySpace() {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - (_horizontalPadding * 2) - (_gridSpacing * 2)) / 3,
      height: TeamButton.maxSize + 30, // 버튼 높이 + 텍스트 영역
    );
  }

  Widget _buildTeamButtonWithWidth(AuthViewModel vm, String code, int index, {bool isHighlighted = false}) {
    final team = TeamData.getByCode(code);
    if (team == null) return SizedBox.shrink();

    final width = (MediaQuery.of(context).size.width - (_horizontalPadding * 2) - (_gridSpacing * 2)) / 3;

    return SizedBox(
      width: width,
      child: TeamButton(
        key: Key('team_button_$code'),
        team: team,
        isSelected: vm.team == code,
        onTap: () => vm.selectTeam(vm.team == code ? null : code),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/constants/team_data.dart';
import 'package:seungyo/components/team_button.dart';
import 'package:seungyo/components/next_button.dart';
import 'package:seungyo/components/title_header.dart';
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
  static const double _horizontalPadding = 16.0;
  static const double _verticalPadding = 26.0;
  static const double _gridSpacing = 12.0;
  static const double _gridRunSpacing = 20.0;

  /// 고정된 그리드 컬럼 수 (기존 방식으로 돌아감)
  static const int _columnCount = 3;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: TitleHeader(title: '정보입력'),
        body: SafeArea(
          child: Column(
            children: [
              // 스크롤 가능한 콘텐츠 영역
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 타이틀 섹션
                        _buildTitle(textTheme),
                        // 팀 선택 그리드
                        _buildTeamGrid(vm),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              // 하단 버튼 영역
              _buildBottomButton(vm),
            ],
          ),
        ),
      ),
    );
  }

  /// 타이틀 섹션 위젯
  Widget _buildTitle(TextTheme textTheme) {
    return Padding(
      key: const Key('team_selection_title'),
      padding: const EdgeInsets.symmetric(vertical: _verticalPadding),
      child: Text(
        '어느 구단을 응원하시나요?',
        style: textTheme.displaySmall,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 팀 선택 그리드 위젯
  Widget _buildTeamGrid(AuthViewModel vm) {
    return Padding(
      key: const Key('team_selection_grid'),
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double itemWidth =
              (constraints.maxWidth - (_gridSpacing * (_columnCount - 1))) /
              _columnCount;

          return Wrap(
            spacing: _gridSpacing,
            runSpacing: _gridRunSpacing,
            alignment: WrapAlignment.start,
            children:
                TeamData.teams.map((team) {
                  final bool isSelected = vm.team == team.name;

                  return SizedBox(
                    width: itemWidth,
                    child: TeamButton(
                      key: Key('team_button_${team.name}'),
                      team: team,
                      isSelected: isSelected,
                      onTap: () => vm.selectTeam(isSelected ? null : team.name),
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  /// 하단 버튼 위젯
  Widget _buildBottomButton(AuthViewModel vm) {
    return Padding(
      key: const Key('team_selection_bottom'),
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        0,
        _horizontalPadding,
        8,
      ),
      child: NextButton(onTap: widget.onNext, isEnabled: vm.team != null),
    );
  }
}

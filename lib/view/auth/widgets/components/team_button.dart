import 'package:flutter/material.dart';
import 'package:seungyo/constants/team_data.dart';

/// 팀 선택 화면에서 사용하는 팀 버튼 컴포넌트
///
/// 사용자가 응원하는 팀을 선택할 수 있는 원형 버튼을 제공합니다.
/// 선택된 팀은 강조 색상과 밑줄로 표시됩니다.
///
/// [team]은 표시할 팀 정보, [isSelected]는 선택 상태, [onTap]은 클릭 이벤트 핸들러입니다.
class TeamButton extends StatelessWidget {
  /// 표시할 팀 정보
  final Team team;

  /// 선택 상태
  final bool isSelected;

  /// 클릭 이벤트 핸들러
  final VoidCallback onTap;

  /// 버튼 최대 크기
  static const double maxSize = 100.0;

  /// 팀 이름 밑줄 높이
  static const double _underlineHeight = 10.0;

  /// 팀 이름과 아이콘 사이 간격
  static const double _verticalSpacing = 6.0;

  const TeamButton({
    super.key,
    required this.team,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // 너비가 충분하지 않으면 가용 너비를 사용
        final size = availableWidth > maxSize ? maxSize : availableWidth;

        // 팀 이름 텍스트 스타일
        final textStyle =
            isSelected
                ? textTheme.bodyLarge?.copyWith(
                  color: colorScheme.primary,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                )
                : textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.1,
                );

        // 원형 배경 스타일
        final circleBackground =
            isSelected ? colorScheme.secondary : colorScheme.surfaceContainer;

        // 테두리 스타일
        final borderColor =
            isSelected ? colorScheme.primary : colorScheme.outline;
        final borderWidth = isSelected ? 2.0 : 1.0;

        return GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 원형 엠블럼 버튼
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: circleBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
                child: Center(
                  child: Image.asset(
                    team.emblem,
                    fit: BoxFit.none,
                    semanticLabel: '${team.name} 팀 엠블럼',
                  ),
                ),
              ),

              SizedBox(height: _verticalSpacing),

              // 팀 이름
              SizedBox(
                width: size,
                height: 20,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 선택 표시용 밑줄 (선택된 경우)
                    if (isSelected)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: size * 0.8, // 팀 이름 너비의 80%
                          height: _underlineHeight,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                    // 팀 이름 텍스트
                    Text(
                      team.name,
                      style: textStyle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:seungyo/constants/team_data.dart';
import 'package:seungyo/theme/app_colors.dart';
import 'package:seungyo/theme/app_text_styles.dart';

/// 팀 선택 화면에서 사용하는 팀 버튼 컴포넌트
///
/// 사용자가 응원하는 팀을 선택할 수 있는 원형 버튼을 제공합니다.
/// 선택된 팀은 강조 색상과 텍스트로 표시됩니다.
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
  static const double maxSize = 85.0;

  /// 팀 이름과 아이콘 사이 간격
  static const double _verticalSpacing = 8.0;

  const TeamButton({super.key, required this.team, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // 너비가 충분하지 않으면 가용 너비를 사용
        final size = availableWidth > maxSize ? maxSize : availableWidth;
        // 텍스트 너비는 버튼보다 20% 더 넓게 설정
        final textWidth = size * 1.2;

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
                  color: isSelected ? AppColors.mint50 : AppColors.navy5,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.navy : AppColors.gray30,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                ),
                child: Center(
                  // 이미지 크기를 조정하여 깔끔하게 표시
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(team.emblem, fit: BoxFit.contain, semanticLabel: '${team.name} 팀 엠블럼'),
                  ),
                ),
              ),

              SizedBox(height: _verticalSpacing),

              // 팀 이름
              Container(
                width: textWidth,
                height: 22, // 높이를 고정하여 텍스트가 짤리지 않도록 함
                child: Text(
                  team.name,
                  style:
                      isSelected
                          ? AppTextStyles.body1.copyWith(color: AppColors.navy)
                          : AppTextStyles.body3.copyWith(color: AppColors.black),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

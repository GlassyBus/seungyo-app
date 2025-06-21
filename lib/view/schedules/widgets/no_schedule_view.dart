import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// 경기 일정 없음 뷰 위젯
class NoScheduleView extends StatelessWidget {
  final bool isAllGamesCanceled;
  final bool hasNoSchedule; // 경기 자체가 없는지 여부

  const NoScheduleView({
    super.key,
    this.isAllGamesCanceled = false,
    this.hasNoSchedule = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      decoration: BoxDecoration(
        // Figma 디자인에 맞춰 배경색 설정
        color: const Color(0xFFF7F8FB), // 모든 경우에 동일한 배경색 사용
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildContent(context),
    );
  }

  /// 상황에 맞는 컨텐츠 선택
  Widget _buildContent(BuildContext context) {
    if (isAllGamesCanceled) {
      return _buildCanceledContent(context);
    } else {
      return _buildNoScheduleContent(context);
    }
  }

  /// 모든 경기가 취소된 경우 컨텐츠 위젯 생성 (Figma 디자인 적용)
  Widget _buildCanceledContent(BuildContext context) {
    return Column(
      children: [
        // 우산 캐릭터 이미지 (배경 제거)
        Container(
          width: 100,
          height: 100,
          child: Image.asset(
            'assets/images/umbrella-120px.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // 이미지 로드 실패 시 우산 아이콘 표시
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.mint10,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.umbrella,
                  size: 50,
                  color: AppColors.mint,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        Text(
          '우천으로 경기가 취소되었어요.',
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 경기 일정 없음 컨텐츠 위젯 생성 (Figma 디자인 적용)
  Widget _buildNoScheduleContent(BuildContext context) {
    return Column(
      children: [
        // Assets 폴더의 break-time 이미지 사용 (쉬는승요 캐릭터)
        Container(
          width: 100,
          height: 100,
          child: Image.asset(
            'assets/images/break-time-120px.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // 이미지 로드 실패 시 아이콘 표시
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.gray20,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_baseball,
                  size: 50,
                  color: AppColors.gray50,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6), // Figma 디자인의 gap: 6px

        Column(
          children: [
            Text(
              '경기가 없는 날이에요.',
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2), // Figma 디자인의 gap: 2px

            Text(
              '일주일에 하루밖에 없는 화나지 않는 날',
              style: AppTextStyles.body3.copyWith(
                color: const Color(0xFF7E8695), // Figma 색상
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}

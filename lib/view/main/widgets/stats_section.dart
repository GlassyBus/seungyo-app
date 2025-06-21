import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'stat_card.dart';

class StatsSection extends StatelessWidget {
  final int totalGames;
  final int winCount;
  final int drawCount;
  final int loseCount;

  const StatsSection({
    super.key,
    required this.totalGames,
    required this.winCount,
    required this.drawCount,
    required this.loseCount,
  });

  @override
  Widget build(BuildContext context) {
    // 데이터가 없는 상태인지 확인 (모든 값이 0인 경우)
    final bool hasData =
        totalGames > 0 || winCount > 0 || drawCount > 0 || loseCount > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '지금까지 직관 기록은',
            style: AppTextStyles.subtitle1.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: '직관',
                  value: totalGames,
                  hasData: hasData,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(label: '승리', value: winCount, hasData: hasData),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: '무승부',
                  value: drawCount,
                  hasData: hasData,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: '패배',
                  value: loseCount,
                  hasData: hasData,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

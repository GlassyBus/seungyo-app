import 'package:flutter/material.dart';
import 'package:seungyo/theme/app_colors.dart';

class RecordSection extends StatelessWidget {
  final int? total;
  final int? win;
  final int? lose;
  const RecordSection({
    super.key,
    this.total = 10,
    this.win = 8,
    this.lose = 2,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '지금까지 직관 기록은',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              const double gap = 16;
              const int count = 3;
              const double minCard = 100;
              const double maxCard = 220;
              double cardWidth = ((constraints.maxWidth - gap * (count - 1)) /
                      count)
                  .clamp(minCard, maxCard);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < count; i++) ...[
                    SizedBox(
                      width: cardWidth,
                      child: _RecordCard(
                        title: ['직관', '승리', '패배'][i],
                        value: [total, win, lose][i],
                        textTheme: textTheme,
                      ),
                    ),
                    if (i != count - 1) const SizedBox(width: gap),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final String title;
  final int? value;
  final TextTheme textTheme;
  const _RecordCard({
    required this.title,
    required this.value,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.gray10,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.gray60,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            value != null ? value.toString() : '-',
            style: textTheme.displayLarge?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

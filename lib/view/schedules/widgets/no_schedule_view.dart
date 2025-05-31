import 'package:flutter/material.dart';

/// 경기 일정 없음 뷰 위젯
class NoScheduleView extends StatelessWidget {
  final bool isRainCanceled;

  const NoScheduleView({Key? key, this.isRainCanceled = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          isRainCanceled
              ? _buildRainCanceledContent(context)
              : _buildNoGameContent(context),
    );
  }

  /// 우천 취소 컨텐츠 위젯 생성
  Widget _buildRainCanceledContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 우산 아이콘
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.umbrella, size: 60, color: colorScheme.outline),
        ),
        const SizedBox(height: 24),
        Text(
          '우천으로 경기가 취소되었어요.',
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 경기 없음 컨텐츠 위젯 생성
  Widget _buildNoGameContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 잠자는 야구공 아이콘
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sports_baseball,
            size: 60,
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '경기가 없는 날이에요.',
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '일주일에 하루밖에 없는 휴식일',
          style: TextStyle(color: colorScheme.outline, fontSize: 14),
        ),
      ],
    );
  }
}

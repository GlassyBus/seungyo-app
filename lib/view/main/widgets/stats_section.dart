import 'package:flutter/material.dart';
import 'stat_card.dart';

class StatsSection extends StatelessWidget {
  final int totalGames;
  final int winCount;
  final int drawCount;
  final int loseCount;

  const StatsSection({
    Key? key,
    required this.totalGames,
    required this.winCount,
    required this.drawCount,
    required this.loseCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '지금까지 직관 기록은',
            style: TextStyle(
              color: Color(0xFF09004C),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'KBO',
              letterSpacing: -0.02,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(label: '직관', value: totalGames)),
              const SizedBox(width: 8),
              Expanded(child: StatCard(label: '승리', value: winCount)),
              const SizedBox(width: 8),
              Expanded(child: StatCard(label: '무승부', value: drawCount)),
              const SizedBox(width: 8),
              Expanded(child: StatCard(label: '패배', value: loseCount)),
            ],
          ),
        ],
      ),
    );
  }
}

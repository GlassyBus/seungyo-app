import 'package:flutter/material.dart';

/// 직관 기록 통계 컴포넌트
///
/// 사용자의 직관 기록 통계(직관, 승리, 패배)를 표시합니다.
class RecordStatsComponent extends StatelessWidget {
  /// 섹션 제목
  final String title;

  /// 총 경기 수
  final int totalGames;

  /// 승리 수
  final int wins;

  /// 무승부 수
  final int draws;

  /// 패배 수
  final int losses;

  /// 승률 (0 ~ 1)
  final double winRate;

  /// 생성자
  const RecordStatsComponent({
    Key? key,
    this.title = '지금까지 직관 기록은',
    this.totalGames = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.winRate = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 계산된 통계 데이터
    final List<Map<String, String>> stats = [
      {'label': '직관', 'value': totalGames.toString()},
      {'label': '승리', 'value': wins.toString()},
      {'label': '무', 'value': draws.toString()},
      {'label': '패배', 'value': losses.toString()},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'KBO Dia Gothic',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.36,
              color: Color(0xFF09004C),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatsCards(stats),
        ],
      ),
    );
  }

  /// 통계 카드들을 가로로 배열한 레이아웃을 빌드합니다.
  Widget _buildStatsCards(List<Map<String, String>> stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          stats
              .map((stat) => _buildStatCard(stat['label']!, stat['value']!))
              .toList(),
    );
  }

  /// 개별 통계 카드를 빌드합니다.
  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'KBO Dia Gothic',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.48,
                color: Color(0xFF656A77),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'KBO Dia Gothic',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.64,
                color: Color(0xFF09004C),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

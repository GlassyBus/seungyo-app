import 'package:flutter/material.dart';
import '../../../models/game_schedule.dart';
import 'game_card.dart';

class TodayGamesSection extends StatelessWidget {
  final List<GameSchedule> todayGames;
  final Function(GameSchedule) onGameEditTap;

  const TodayGamesSection({
    Key? key,
    required this.todayGames,
    required this.onGameEditTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[now.weekday % 7];
    final dateString =
        '${now.year}. ${now.month.toString().padLeft(2, '0')}. ${now.day.toString().padLeft(2, '0')}($weekday)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '오늘의 경기는',
                style: TextStyle(
                  color: Color(0xFF09004C),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'KBO',
                  letterSpacing: -0.02,
                ),
              ),
              Text(
                dateString,
                style: const TextStyle(
                  color: Color(0xFF100F21),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'KBO',
                  letterSpacing: -0.03,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGamesList(),
        ],
      ),
    );
  }

  Widget _buildGamesList() {
    if (todayGames.isEmpty) {
      return _buildNoGameToday();
    }

    return Column(
      children:
          todayGames
              .map(
                (game) =>
                    GameCard(game: game, onEditTap: () => onGameEditTap(game)),
              )
              .toList(),
    );
  }

  Widget _buildNoGameToday() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.sports_baseball, size: 60, color: Color(0xFF656A77)),
          SizedBox(height: 16),
          Text(
            '오늘은 경기가 없습니다',
            style: TextStyle(
              color: Color(0xFF656A77),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '휴식의 날입니다',
            style: TextStyle(color: Color(0xFF656A77), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

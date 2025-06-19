import 'package:flutter/material.dart';

import '../../../models/game_record.dart';
import '../../../models/game_schedule.dart';
import '../../../widgets/game_section_widget.dart';

class TodayGamesSection extends StatelessWidget {
  final List<GameSchedule> todayGames;
  final List<GameRecord> attendedRecords; // 직관 기록 리스트
  final Function(GameSchedule) onGameEditTap;

  const TodayGamesSection({
    Key? key,
    required this.todayGames,
    required this.attendedRecords,
    required this.onGameEditTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('TodayGamesSection: Building with ${todayGames.length} games');
    for (int i = 0; i < todayGames.length; i++) {
      final game = todayGames[i];
      print(
        'TodayGamesSection: Game $i - ${game.homeTeam} vs ${game.awayTeam} at ${game.stadium}',
      );
    }

    final now = DateTime.now();
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[(now.weekday) % 7];
    final dateString =
        '${now.year}. ${now.month.toString().padLeft(2, '0')}. ${now.day.toString().padLeft(2, '0')}($weekday)';

    return GameSectionWidget(
      title: '오늘의 경기는',
      subtitle: dateString,
      games: todayGames,
      attendedRecords: attendedRecords,
      onGameTap: onGameEditTap,
      emptyMessage: '경기가 없는 날이에요.',
    );
  }
}
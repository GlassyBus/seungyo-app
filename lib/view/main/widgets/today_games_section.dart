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
      print('TodayGamesSection: Game $i - ${game.homeTeam} vs ${game.awayTeam} at ${game.stadium}');
    }

    final now = DateTime.now();
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[(now.weekday) % 7];
    final dateString =
        '${now.year}. ${now.month.toString().padLeft(2, '0')}. ${now.day.toString().padLeft(2, '0')}($weekday)';

    // 직관 기록이 있는 경기를 우선으로 정렬
    final sortedGames = _sortGamesByRecord(todayGames);

    return GameSectionWidget(
      title: '오늘의 경기는',
      subtitle: dateString,
      games: sortedGames,
      attendedRecords: attendedRecords,
      onGameTap: onGameEditTap,
      emptyMessage: '경기가 없는 날이에요.',
    );
  }

  /// 직관 기록이 있는 경기를 우선으로 정렬
  List<GameSchedule> _sortGamesByRecord(List<GameSchedule> games) {
    final gamesWithRecord = <GameSchedule>[];
    final gamesWithoutRecord = <GameSchedule>[];

    for (final game in games) {
      final hasRecord = attendedRecords.any((record) {
        final recordDate = record.dateTime;
        final gameDate = game.dateTime;

        return recordDate.year == gameDate.year &&
            recordDate.month == gameDate.month &&
            recordDate.day == gameDate.day &&
            record.homeTeam.name.contains(game.homeTeam) &&
            record.awayTeam.name.contains(game.awayTeam);
      });

      if (hasRecord) {
        gamesWithRecord.add(game);
      } else {
        gamesWithoutRecord.add(game);
      }
    }

    // 직관 기록이 있는 경기를 먼저, 그 다음에 없는 경기
    return [...gamesWithRecord, ...gamesWithoutRecord];
  }
}

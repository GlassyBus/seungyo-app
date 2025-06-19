import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../models/game_record.dart';
import '../models/game_schedule.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../view/main/widgets/game_card.dart';

/// 경기 목록을 표시하는 재사용 가능한 위젯
class GameListWidget extends StatelessWidget {
  final List<GameSchedule> games;
  final List<GameRecord> attendedRecords;
  final Function(GameSchedule) onGameTap;
  final String? emptyMessage;
  final Widget? emptyWidget;
  final bool showDate;
  final EdgeInsetsGeometry? padding;

  const GameListWidget({
    Key? key,
    required this.games,
    required this.attendedRecords,
    required this.onGameTap,
    this.emptyMessage,
    this.emptyWidget,
    this.showDate = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. 경기가 아예 없는 경우
    if (games.isEmpty) {
      return _buildEmptyState();
    }

    // 2. 모든 경기가 취소된 경우 (우천 취소)
    final allGamesCanceled = games.every((game) => game.status == GameStatus.canceled);
    if (allGamesCanceled) {
      return _buildCanceledGames();
    }

    // 3. 직관 기록이 있는 경기를 우선으로 정렬
    final sortedGames = _sortGamesByRecord(games);

    // 4. 정상적인 경기가 있는 경우
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 20),
      child: Column(
        children:
            sortedGames.map((game) {
              // 해당 경기에 대한 직관 기록이 있는지 확인
              final attendedRecord = _findAttendedRecord(game);

              return GameCard(game: game, attendedRecord: attendedRecord, onEditTap: () => onGameTap(game));
            }).toList(),
      ),
    );
  }

  /// 직관 기록이 있는 경기를 우선으로 정렬
  List<GameSchedule> _sortGamesByRecord(List<GameSchedule> gameList) {
    final gamesWithRecord = <GameSchedule>[];
    final gamesWithoutRecord = <GameSchedule>[];

    for (final game in gameList) {
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

  /// 해당 경기에 대한 직관 기록을 찾는 함수
  GameRecord? _findAttendedRecord(GameSchedule game) {
    return attendedRecords.firstWhereOrNull((record) {
      final recordDate = record.dateTime;
      final gameDate = game.dateTime;

      // 같은 날짜이고 같은 팀 매치업인지 확인
      return recordDate.year == gameDate.year &&
          recordDate.month == gameDate.month &&
          recordDate.day == gameDate.day &&
          record.homeTeam.name.contains(game.homeTeam) &&
          record.awayTeam.name.contains(game.awayTeam);
    });
  }

  Widget _buildEmptyState() {
    if (emptyWidget != null) {
      return emptyWidget!;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/break-time-120px.png', // 승요 캐릭터 (평상시)
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            emptyMessage ?? '경기가 없는 날이에요.',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w500, color: AppColors.black),
          ),
          const SizedBox(height: 4),
          Text(
            '일주일에 하루밖에 없는 화나지 않는 날',
            textAlign: TextAlign.center,
            style: AppTextStyles.body3.copyWith(color: AppColors.gray80, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCanceledGames() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/umbrella-120px.png', // 우산 든 승요 캐릭터
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            '우천으로 취소되었어요.',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w500, color: AppColors.black),
          ),
        ],
      ),
    );
  }
}

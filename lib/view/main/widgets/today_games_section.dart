import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../models/game_record.dart';
import '../../../models/game_schedule.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'game_card.dart';

class TodayGamesSection extends StatelessWidget {
  final List<GameSchedule> todayGames;
  final List<GameRecord> attendedRecords; // 직관 기록 리스트 추가
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

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '오늘의 경기는',
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                dateString,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildGamesList(),
        ],
      ),
    );
  }

  Widget _buildGamesList() {
    print(
      'TodayGamesSection: _buildGamesList called with ${todayGames.length} games',
    );

    // 1. 경기가 아예 없는 경우
    if (todayGames.isEmpty) {
      print('TodayGamesSection: No games today');
      return _buildNoGameToday();
    }

    // 2. 모든 경기가 취소된 경우 (우천 취소)
    final allGamesCanceled = todayGames.every(
      (game) => game.status == GameStatus.canceled,
    );
    if (allGamesCanceled) {
      print('TodayGamesSection: All games canceled');
      return _buildCanceledGames();
    }

    // 3. 정상적인 경기가 있는 경우
    print('TodayGamesSection: Building ${todayGames.length} game cards');
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children:
            todayGames
                .map(
                  (game) {
                    // 해당 경기에 대한 직관 기록이 있는지 확인
                    final attendedRecord = _findAttendedRecord(game);
                    
                    return GameCard(
                      game: game,
                      attendedRecord: attendedRecord,
                      onEditTap: () => onGameEditTap(game),
                    );
                  },
                )
                .toList(),
      ),
    );
  }

  Widget _buildNoGameToday() {
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
            '경기가 없는 날이에요.',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '일주일에 하루밖에 없는 화나지 않는 날',
            textAlign: TextAlign.center,
            style: AppTextStyles.body3.copyWith(
              color: AppColors.gray80,
              fontWeight: FontWeight.w500,
            ),
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
            style: AppTextStyles.subtitle1.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// 해당 경기에 대한 직관 기록을 찾는 함수
  GameRecord? _findAttendedRecord(GameSchedule game) {
    return attendedRecords.firstWhereOrNull(
      (record) {
        final recordDate = record.dateTime;
        final gameDate = game.dateTime;

        // 같은 날짜이고 같은 팀 매치업인지 확인
        return recordDate.year == gameDate.year &&
            recordDate.month == gameDate.month &&
            recordDate.day == gameDate.day &&
            record.homeTeam.name.contains(game.homeTeam) &&
            record.awayTeam.name.contains(game.awayTeam);
      },
    );
  }
}
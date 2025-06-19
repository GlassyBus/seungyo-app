import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/game_record.dart';
import '../../../models/game_schedule.dart';
import '../../../theme/theme.dart';

/// 경기 일정 아이템 위젯
class ScheduleItem extends StatelessWidget {
  final GameSchedule schedule;
  final VoidCallback? onTap;

  const ScheduleItem({Key? key, required this.schedule, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(textTheme),
                const SizedBox(height: 16),
                _buildTeamsInfo(textTheme),
                if (_shouldShowActionButton()) _buildActionButton(textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 위젯 생성
  Widget _buildHeader(TextTheme textTheme) {
    final timeFormat = DateFormat('HH:mm');
    final formattedTime = timeFormat.format(schedule.dateTime);

    final badgeInfo = _getBadgeInfo();

    return Row(
      children: [
        if (badgeInfo.text.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: badgeInfo.color, borderRadius: BorderRadius.circular(6)),
            child: Text(
              badgeInfo.text,
              style: textTheme.bodySmall?.copyWith(color: badgeInfo.textColor, fontWeight: FontWeight.bold),
            ),
          ),
        if (badgeInfo.text.isNotEmpty) const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${schedule.stadium}, ${formattedTime}',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.navy, fontWeight: FontWeight.bold),
          ),
        ),
        if (schedule.hasAttended) Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray50),
      ],
    );
  }

  /// 팀 정보 위젯 생성
  Widget _buildTeamsInfo(TextTheme textTheme) {
    return Row(
      children: [
        // 홈팀 정보
        Expanded(
          child: Row(
            children: [
              Image.asset(
                schedule.homeTeamLogo ?? 'assets/emblems/bears.png',
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('⚾', style: TextStyle(fontSize: 24));
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  schedule.homeTeam,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // 스코어 또는 VS
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:
              schedule.status == GameStatus.finished
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${schedule.homeScore}', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(':', style: textTheme.titleLarge?.copyWith(color: AppColors.gray50)),
                      const SizedBox(width: 8),
                      Text('${schedule.awayScore}', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  )
                  : Text(
                    'VS',
                    style: textTheme.titleLarge?.copyWith(color: AppColors.gray50, fontWeight: FontWeight.bold),
                  ),
        ),

        // 원정팀 정보
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  schedule.awayTeam,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                schedule.awayTeamLogo ?? 'assets/emblems/bears.png',
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('⚾', style: TextStyle(fontSize: 24));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 액션 버튼 위젯 생성
  Widget _buildActionButton(TextTheme textTheme) {
    if (schedule.hasAttended) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: AppColors.mint.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility_outlined, size: 16, color: AppColors.navy),
              const SizedBox(width: 4),
              Text(
                '직관 기록 보기',
                style: textTheme.bodySmall?.copyWith(color: AppColors.navy, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    } else if (schedule.status != GameStatus.finished &&
        schedule.status != GameStatus.canceled &&
        schedule.status != GameStatus.postponed) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: 직관 기록 추가 화면으로 이동
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 24,
            color: AppColors.gray50,
            tooltip: '직관 기록 추가',
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 배지 정보 가져오기
  _BadgeInfo _getBadgeInfo() {
    if (schedule.status == GameStatus.finished) {
      switch (schedule.result) {
        case GameResult.win:
          return _BadgeInfo(color: AppColors.mint, textColor: AppColors.navy, text: 'WIN');
        case GameResult.lose:
          return _BadgeInfo(color: AppColors.navy, textColor: Colors.white, text: 'LOSE');
        case GameResult.draw:
          return _BadgeInfo(color: AppColors.gray30, textColor: AppColors.black, text: 'DRAW');
        default:
          return _BadgeInfo(color: AppColors.gray10, textColor: AppColors.gray70, text: '종료');
      }
    } else if (schedule.status == GameStatus.inProgress) {
      return _BadgeInfo(color: Colors.red, textColor: Colors.white, text: 'LIVE');
    } else if (schedule.status == GameStatus.postponed) {
      return _BadgeInfo(color: Colors.orange, textColor: Colors.white, text: 'PPD');
    } else if (schedule.status == GameStatus.canceled) {
      return _BadgeInfo(color: AppColors.gray30, textColor: AppColors.black, text: '취소');
    }

    return _BadgeInfo(color: Colors.transparent, textColor: Colors.transparent, text: '');
  }

  /// 액션 버튼 표시 여부 확인
  bool _shouldShowActionButton() {
    return schedule.hasAttended ||
        (schedule.status != GameStatus.finished &&
            schedule.status != GameStatus.canceled &&
            schedule.status != GameStatus.postponed);
  }
}

/// 배지 정보 클래스
class _BadgeInfo {
  final Color color;
  final Color textColor;
  final String text;

  _BadgeInfo({required this.color, required this.textColor, required this.text});
}

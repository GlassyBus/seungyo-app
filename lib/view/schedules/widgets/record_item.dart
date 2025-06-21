import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/game_record.dart';
import '../../../theme/app_colors.dart';

/// 직관 기록 아이템 위젯
class RecordItem extends StatelessWidget {
  final GameRecord record;
  final VoidCallback? onTap;

  const RecordItem({super.key, required this.record, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray5,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                if (record.seatInfo != null && record.seatInfo!.isNotEmpty)
                  _buildSeatInfo(textTheme),
                if (record.isFavorite) _buildFavoriteIndicator(textTheme),
                if (_isWinRecord()) _buildViewRecordLink(textTheme),
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
    final formattedTime = timeFormat.format(record.dateTime);

    final badgeInfo = _getBadgeInfo();

    return Row(
      children: [
        if (badgeInfo.text.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeInfo.color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badgeInfo.text,
              style: textTheme.bodySmall?.copyWith(
                color: badgeInfo.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (badgeInfo.text.isNotEmpty) const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${record.stadium.name}, $formattedTime',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray50),
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
                record.homeTeam.logo ?? 'assets/emblems/bears.png',
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('⚾', style: TextStyle(fontSize: 24));
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  record.homeTeam.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // 스코어
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${record.homeScore}',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ':',
                style: textTheme.titleLarge?.copyWith(color: AppColors.gray50),
              ),
              const SizedBox(width: 8),
              Text(
                '${record.awayScore}',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // 원정팀 정보
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  record.awayTeam.name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                record.awayTeam.logo ?? 'assets/emblems/bears.png',
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

  /// 좌석 정보 위젯 생성
  Widget _buildSeatInfo(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.event_seat, size: 16, color: AppColors.gray50),
          const SizedBox(width: 4),
          Text(
            record.seatInfo!,
            style: textTheme.bodySmall?.copyWith(color: AppColors.gray70),
          ),
        ],
      ),
    );
  }

  /// 즐겨찾기 표시 위젯 생성
  Widget _buildFavoriteIndicator(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.favorite, size: 16, color: Colors.red),
          const SizedBox(width: 4),
          Text(
            '즐겨찾기',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 배지 정보 가져오기
  _BadgeInfo _getBadgeInfo() {
    if (record.canceled) {
      return _BadgeInfo(
        color: AppColors.gray30,
        textColor: AppColors.gray70,
        text: 'PPD',
      );
    }

    // 승부 결과 확인
    if (record.homeScore > record.awayScore) {
      // 홈팀 승리
      return _BadgeInfo(
        color: AppColors.mint,
        textColor: AppColors.navy,
        text: 'WIN',
      );
    } else if (record.homeScore < record.awayScore) {
      // 원정팀 승리 (홈팀 패배)
      return _BadgeInfo(
        color: AppColors.navy,
        textColor: Colors.white,
        text: 'LOSE',
      );
    } else {
      // 무승부
      return _BadgeInfo(
        color: AppColors.gray30,
        textColor: AppColors.black,
        text: 'DRAW',
      );
    }
  }

  bool _isWinRecord() {
    return record.homeScore > record.awayScore;
  }

  Widget _buildViewRecordLink(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.link, size: 16, color: AppColors.gray50),
          const SizedBox(width: 4),
          Text(
            '직관 기록 보기',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.gray50,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 배지 정보 클래스
class _BadgeInfo {
  final Color color;
  final Color textColor;
  final String text;

  _BadgeInfo({
    required this.color,
    required this.textColor,
    required this.text,
  });
}

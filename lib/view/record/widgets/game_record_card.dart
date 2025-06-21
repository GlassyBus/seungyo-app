import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seungyo/theme/app_text_styles.dart';
import 'package:seungyo/utils/date_formatter.dart';

import '../../../models/game_record.dart';
import 'dotted_line_painter.dart';

/// 게임 기록 카드 위젯 - DB 데이터를 사용하여 모든 데이터를 props로 받음
class GameRecordCard extends StatelessWidget {
  const GameRecordCard({
    super.key,
    required this.record,
    this.onTap,
    this.onFavoriteToggle,
  });

  final GameRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    const double cardActualHeight = 110.0;
    const double cardPadding = 6.0;
    const double cardTotalHeight = cardActualHeight;

    const double cardBorderRadius = 16.0;
    const double imageBorderRadius = 12.0;

    return Container(
      height: cardTotalHeight,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD3D9E9).withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(cardPadding),
      child: ClipRRect(
        child: InkWell(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildGameImage(context, imageBorderRadius, cardActualHeight),
              Expanded(child: _buildGameInfo(context, cardActualHeight)),
              _buildVerticalDottedLine(cardActualHeight),
              _buildResultSection(context, cardActualHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameImage(
    BuildContext context,
    double borderRadius,
    double rowContentHeight,
  ) {
    const double imageWidth = 90.0;
    const double imageHeight = 98.0;

    return SizedBox(
      width: imageWidth,
      height: imageHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          color: const Color(0xFFF0F2F5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // DB에서 photos 배열의 첫 번째 이미지 사용 (로컬 파일 경로)
              record.photos.isNotEmpty
                  ? Image.file(
                    File(record.photos.first),
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            _buildDefaultImagePlaceholder(),
                  )
                  : _buildDefaultImagePlaceholder(),
              if (onFavoriteToggle != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        record.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        color:
                            record.isFavorite
                                ? const Color(0xFFEB4144)
                                : Colors.white,
                        size: 22.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultImagePlaceholder() {
    return Container(
      color: const Color(0xFFF0F2F5),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/icons/wings-57px.svg',
        width: 57,
        height: 69,
      ),
    );
  }

  Widget _buildGameInfo(BuildContext context, double contentHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: contentHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 날짜 및 경기장 정보
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormatter.formatFullDateTime(record.dateTime),
                  style: AppTextStyles.caption.copyWith(
                    color: const Color(0xFF8A94A8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  record.stadium.name,
                  style: AppTextStyles.subtitle2.copyWith(
                    color: const Color(0xFF09004C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 팀 이름 정보 - DB에서 실제 팀명 사용
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    record.homeTeam.shortName,
                    style: AppTextStyles.body1.copyWith(
                      color: const Color(0xFF09004C),
                      fontSize: 22,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'VS',
                    style: AppTextStyles.body3.copyWith(
                      color: const Color(0xFF8A94A8),
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    record.awayTeam.shortName,
                    style: AppTextStyles.body1.copyWith(
                      color: const Color(0xFF09004C),
                      fontSize: 22,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDottedLine(double contentHeight) {
    return Container(
      width: 10,
      height: contentHeight,
      child: CustomPaint(painter: DottedLinePainter()),
    );
  }

  Widget _buildResultSection(BuildContext context, double contentHeight) {
    const double resultSectionWidth = 86.0;
    final (badgeColor, badgeTextColor, resultText) = _getResultStyle(
      record.result,
    );

    return SizedBox(
      width: resultSectionWidth,
      height: contentHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 결과 배지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                resultText,
                style: AppTextStyles.body3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: badgeTextColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // 점수
            if (record.result == GameResult.cancel)
              Text(
                '-',
                style: AppTextStyles.body1.copyWith(
                  color: const Color(0xFF8A94A8), // black60
                  fontSize: 28,
                ),
              )
            else if (record.homeScore != null && record.awayScore != null)
              Text(
                '${record.homeScore}:${record.awayScore}',
                style: AppTextStyles.body1.copyWith(
                  color: const Color(0xFF09004C),
                  fontSize: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }

  (Color, Color, String) _getResultStyle(GameResult result) {
    switch (result) {
      case GameResult.win:
        return (const Color(0xFF57FFCF), const Color(0xFF09004C), 'WIN');
      case GameResult.lose:
        return (const Color(0xFF09004C), Colors.white, 'LOSE');
      case GameResult.draw:
        return (const Color(0xFFE6EAF2), const Color(0xFF09004C), 'DRAW');
      case GameResult.cancel:
        return (const Color(0xFFE6EAF2), const Color(0xFF8A94A8), 'PPD');
    }
  }
}

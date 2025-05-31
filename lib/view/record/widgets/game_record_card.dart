import 'package:flutter/material.dart';
import 'package:seungyo/theme/app_colors.dart';
import 'package:seungyo/utils/date_formatter.dart';

import '../../../models/game_record.dart';

/// 게임 기록 카드 위젯 - 모든 데이터를 props로 받음
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildGameImage(colorScheme),
              const SizedBox(width: 16),
              Expanded(child: _buildGameInfo(textTheme, colorScheme)),
              const SizedBox(width: 16),
              _buildResultSection(textTheme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameImage(ColorScheme colorScheme) {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              record.imageUrl != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      record.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              _buildDefaultImage(colorScheme),
                    ),
                  )
                  : _buildDefaultImage(colorScheme),
        ),
        if (onFavoriteToggle != null)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  record.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: record.isFavorite ? colorScheme.error : Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultImage(ColorScheme colorScheme) {
    return Icon(Icons.sports_baseball, color: colorScheme.outline, size: 24);
  }

  Widget _buildGameInfo(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormatter.formatFullDateTime(record.dateTime),
          style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
        ),
        const SizedBox(height: 4),
        Text(
          record.stadium.name,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              record.homeTeam.shortName,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Text('VS'),
            const SizedBox(width: 8),
            Text(
              record.awayTeam.shortName,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultSection(TextTheme textTheme, ColorScheme colorScheme) {
    final (resultColor, textColor) = _getResultColors(colorScheme);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: resultColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            record.result.displayName,
            style: textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${record.homeScore}:${record.awayScore}',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  (Color, Color) _getResultColors(ColorScheme colorScheme) {
    switch (record.result) {
      case GameResult.win:
        return (colorScheme.secondary, colorScheme.onSecondary);
      case GameResult.lose:
        return (colorScheme.errorContainer, colorScheme.onErrorContainer);
      case GameResult.draw:
        return (colorScheme.surfaceContainerHigh, colorScheme.onSurface);
    }
  }
}

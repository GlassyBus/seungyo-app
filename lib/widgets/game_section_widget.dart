import 'package:flutter/material.dart';

import '../models/game_record.dart';
import '../models/game_schedule.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'game_list_widget.dart';

/// 헤더와 경기 목록을 함께 표시하는 섹션 위젯
class GameSectionWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<GameSchedule> games;
  final List<GameRecord> attendedRecords;
  final Function(GameSchedule) onGameTap;
  final String? emptyMessage;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;
  final Widget? headerTrailing;

  const GameSectionWidget({
    Key? key,
    required this.title,
    this.subtitle,
    required this.games,
    required this.attendedRecords,
    required this.onGameTap,
    this.emptyMessage,
    this.emptyWidget,
    this.padding,
    this.headerTrailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          GameListWidget(
            games: games,
            attendedRecords: attendedRecords,
            onGameTap: onGameTap,
            emptyMessage: emptyMessage,
            emptyWidget: emptyWidget,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w400,
            ),
          )
        else if (headerTrailing != null)
          headerTrailing!,
      ],
    );
  }
}

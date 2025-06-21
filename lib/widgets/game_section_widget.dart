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
  final bool isLoading; // 로딩 상태 추가

  const GameSectionWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.games,
    required this.attendedRecords,
    required this.onGameTap,
    this.emptyMessage,
    this.emptyWidget,
    this.padding,
    this.headerTrailing,
    this.isLoading = false, // 기본값 false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 제목이 비어있지 않을 때만 헤더 표시
          if (title.isNotEmpty) ...[_buildHeader(), const SizedBox(height: 20)],

          // 🔄 로딩 중일 때
          if (isLoading)
            _buildLoadingWidget()
          else
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

  Widget _buildLoadingWidget() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.gray5,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF09004C),
              ),
            ),
            SizedBox(height: 12),
            Text(
              '경기 일정을 불러오는 중...',
              style: TextStyle(
                color: Color(0xFF7E8695),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
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

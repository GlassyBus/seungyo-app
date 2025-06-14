import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seungyo/theme/theme.dart';

import '../../models/game_record.dart';
import '../../widgets/custom_checkbox.dart';
import 'create_record_screen.dart';
import 'widgets/action_modal.dart';

class RecordDetailPage extends StatefulWidget {
  final GameRecord game;

  const RecordDetailPage({Key? key, required this.game}) : super(key: key);

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  bool isGameMinimum = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(),
      body: _buildBody(colorScheme, textTheme),
      bottomNavigationBar: _buildBottomNavigationBar(colorScheme),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('직관 기록 상세'),
      actions: [
        IconButton(icon: const Icon(Icons.edit), onPressed: _handleEdit),
        IconButton(icon: const Icon(Icons.download), onPressed: _handleDownload),
        IconButton(icon: const Icon(Icons.more_horiz), onPressed: _showActionModal),
      ],
    );
  }

  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainImage(),
          _buildGameInfo(textTheme),
          const SizedBox(height: 32),
          _buildGameResultSection(colorScheme, textTheme),
          const SizedBox(height: 32),
          _buildCommentSection(colorScheme, textTheme),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMainImage() {
    return Container(
      width: double.infinity,
      height: 300,
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            widget.game.photos.isNotEmpty
                ? PageView.builder(
                  itemCount: widget.game.photos.length,
                  itemBuilder: (context, index) {
                    return Image.file(
                      File(widget.game.photos[index]),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: AppColors.gray20,
                            child: const Center(child: Icon(Icons.image, size: 80, color: AppColors.gray50)),
                          ),
                    );
                  },
                )
                : Container(
                  color: AppColors.gray20,
                  child: const Center(child: Icon(Icons.image, size: 80, color: AppColors.gray50)),
                ),
      ),
    );
  }

  Widget _buildGameInfo(TextTheme textTheme) {
    final dateFormat = DateFormat('yyyy.MM.dd(E) HH:mm', 'ko_KR');
    final formattedDate = dateFormat.format(widget.game.dateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildInfoRow('일정', formattedDate, textTheme),
          const SizedBox(height: 16),
          _buildInfoRow('위치', widget.game.stadium.name, textTheme),
          const SizedBox(height: 16),
          _buildInfoRow('좌석', widget.game.seatInfo ?? '', textTheme),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, TextTheme textTheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 60, child: Text(label, style: textTheme.bodyMedium?.copyWith(color: AppColors.gray70))),
        const SizedBox(width: 20),
        Expanded(child: Text(value, style: textTheme.bodyLarge)),
      ],
    );
  }

  Widget _buildGameResultSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('경기 정보', style: textTheme.titleLarge?.copyWith(color: AppColors.gray70)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.navy5, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildTeamLabels(textTheme),
                const SizedBox(height: 16),
                _buildScoreDisplay(textTheme),
                const SizedBox(height: 20),
                _buildGameMinimumCheckbox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLabels(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('홈팀', style: textTheme.bodySmall?.copyWith(color: AppColors.gray70)),
        Text('상대팀', style: textTheme.bodySmall?.copyWith(color: AppColors.gray70)),
      ],
    );
  }

  Widget _buildScoreDisplay(TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTeamInfo(
          widget.game.homeTeam.name,
          widget.game.homeTeam.primaryColor,
          widget.game.homeTeam.logoUrl ?? '⚾',
          textTheme,
        ),
        Text('${widget.game.homeScore}', style: textTheme.displayLarge),
        Text(':', style: textTheme.displayLarge?.copyWith(color: AppColors.gray50)),
        Text('${widget.game.awayScore}', style: textTheme.displayLarge),
        _buildTeamInfo(
          widget.game.awayTeam.name,
          widget.game.awayTeam.primaryColor,
          widget.game.awayTeam.logoUrl ?? '⚾',
          textTheme,
        ),
      ],
    );
  }

  Widget _buildTeamInfo(String teamName, Color color, String logoText, TextTheme textTheme) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Text(
              logoText,
              style: textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(teamName, style: textTheme.titleMedium),
      ],
    );
  }

  Widget _buildGameMinimumCheckbox() {
    return Align(
      alignment: Alignment.centerLeft,
      child: CustomCheckbox(
        value: isGameMinimum,
        onChanged: (value) {
          setState(() {
            isGameMinimum = value;
          });
        },
        label: '경기최소',
      ),
    );
  }

  Widget _buildCommentSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('코멘트', style: textTheme.titleLarge?.copyWith(color: AppColors.gray70)),
          const SizedBox(height: 16),
          Text(widget.game.memo, style: textTheme.bodyLarge),
          const SizedBox(height: 24),
          Center(child: Text('기억에 남는 경기였나요?', style: textTheme.bodyMedium?.copyWith(color: AppColors.gray70))),
          const SizedBox(height: 16),
          Center(
            child: AnimatedScale(
              scale: widget.game.isFavorite ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.favorite,
                color: widget.game.isFavorite ? AppColors.negative : AppColors.gray30,
                size: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.gray10, width: 1))),
      child: BottomNavigationBar(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.onSurface,
        unselectedItemColor: AppColors.gray50,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.sports_baseball_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: ''),
        ],
      ),
    );
  }

  void _handleDownload() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('다운로드 기능을 구현해주세요')));
  }

  void _showActionModal() {
    RecordActionModal.show(context, onEdit: _handleEdit, onDelete: _handleDelete);
  }

  void _handleEdit() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateRecordScreen(gameRecord: widget.game))).then((
      result,
    ) {
      if (result == true) {
        Navigator.pop(context, true);
      }
    });
  }

  void _handleDelete() {
    _showDeleteConfirmDialog();
  }

  void _showDeleteConfirmDialog() {
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('기록 삭제', style: textTheme.titleLarge),
            content: Text('이 기록을 삭제하시겠습니까?\n삭제된 기록은 복구할 수 없습니다.', style: textTheme.bodyMedium),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('취소', style: textTheme.bodyMedium)),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('기록이 삭제되었습니다')));
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.negative),
                child: Text('삭제', style: textTheme.bodyMedium),
              ),
            ],
          ),
    );
  }
}

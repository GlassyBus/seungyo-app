import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:seungyo/models/team.dart' as app_models;
import 'package:seungyo/services/database_service.dart';
import 'package:seungyo/theme/theme.dart';

class ScoreInputModal extends StatefulWidget {
  final String homeTeam;
  final String awayTeam;
  final int? initialHomeScore;
  final int? initialAwayScore;
  final Function(int homeScore, int awayScore) onScoreSelected;

  const ScoreInputModal({
    Key? key,
    required this.homeTeam,
    required this.awayTeam,
    this.initialHomeScore,
    this.initialAwayScore,
    required this.onScoreSelected,
  }) : super(key: key);

  @override
  State<ScoreInputModal> createState() => _ScoreInputModalState();
}

class _ScoreInputModalState extends State<ScoreInputModal> {
  late int _homeScore;
  late int _awayScore;
  app_models.Team? _homeTeamData;
  app_models.Team? _awayTeamData;

  @override
  void initState() {
    super.initState();
    _homeScore = widget.initialHomeScore ?? 0;
    _awayScore = widget.initialAwayScore ?? 0;
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    try {
      final teams = await DatabaseService().getTeamsAsAppModels();
      setState(() {
        _homeTeamData = teams.firstWhereOrNull((t) => t.id == widget.homeTeam);
        _awayTeamData = teams.firstWhereOrNull((t) => t.id == widget.awayTeam);
      });
    } catch (e) {
      print('Error loading team data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(colorScheme, textTheme),
          Expanded(child: _buildScoreInput(colorScheme, textTheme)),
          _buildConfirmButton(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.gray10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('경기 결과 입력', style: textTheme.titleLarge),
          IconButton(icon: Icon(Icons.close, color: colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildScoreInput(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('홈팀', style: textTheme.bodySmall?.copyWith(color: AppColors.gray70)),
              Text('상대팀', style: textTheme.bodySmall?.copyWith(color: AppColors.gray70)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_homeTeamData?.name ?? '홈팀', style: textTheme.titleMedium),
              Text(_awayTeamData?.name ?? '상대팀', style: textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreCounter(_homeScore, (value) => setState(() => _homeScore = value), textTheme),
              Text(':', style: textTheme.displayLarge?.copyWith(color: AppColors.gray50)),
              _buildScoreCounter(_awayScore, (value) => setState(() => _awayScore = value), textTheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCounter(int score, Function(int) onChanged, TextTheme textTheme) {
    return Column(
      children: [
        IconButton(
          onPressed: () => onChanged(score + 1),
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text('$score', style: textTheme.displayLarge),
        const SizedBox(height: 16),
        IconButton(
          onPressed: score > 0 ? () => onChanged(score - 1) : null,
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: score > 0 ? AppColors.navy : AppColors.gray30,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.remove, color: score > 0 ? Colors.white : AppColors.gray50),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            widget.onScoreSelected(_homeScore, _awayScore);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('확인', style: AppTextStyles.button1.copyWith(color: Colors.white)),
        ),
      ),
    );
  }
}

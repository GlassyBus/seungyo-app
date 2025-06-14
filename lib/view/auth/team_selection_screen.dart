import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../services/team_service.dart';
import '../../models/team.dart';

class TeamSelectionPage extends StatefulWidget {
  final String? currentTeamId;

  const TeamSelectionPage({Key? key, this.currentTeamId}) : super(key: key);

  @override
  State<TeamSelectionPage> createState() => _TeamSelectionPageState();
}

class _TeamSelectionPageState extends State<TeamSelectionPage> {
  String? _selectedTeamId;
  final TeamService _teamService = TeamService();
  List<Team> _teams = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedTeamId = widget.currentTeamId;
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final teams = await _teamService.getAllTeams();

      if (teams.isEmpty) {
        throw Exception('팀 목록이 비어있습니다');
      }

      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
        _errorMessage = '팀 목록을 불러오는데 실패했습니다: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('응원 구단 변경', style: textTheme.titleLarge),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    '어느 구단을 응원하시나요?',
                    style: textTheme.displaySmall?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _buildContent(),
                ],
              ),
            ),
          ),
          _buildBottomButton(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadTeams, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    return _buildTeamGrid();
  }

  Widget _buildTeamGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      itemCount: _teams.length,
      itemBuilder: (context, index) {
        final team = _teams[index];
        final isSelected = _selectedTeamId == team.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTeamId = team.id;
            });
          },
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.mint : AppColors.gray10,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.mint : AppColors.gray20,
                    width: isSelected ? 3 : 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    team.logo ?? '⚾',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                team.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.navy : AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomButton(ColorScheme colorScheme, TextTheme textTheme) {
    Team? selectedTeam;

    if (_selectedTeamId != null && _teams.isNotEmpty) {
      try {
        final results = _teams.where((team) => team.id == _selectedTeamId);
        selectedTeam = results.isNotEmpty ? results.first : null;
      } catch (e) {
        selectedTeam = null;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed:
              selectedTeam != null && !_isLoading
                  ? () => Navigator.pop(context, selectedTeam)
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.navy,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.gray30,
            disabledForegroundColor: AppColors.gray50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text(
                    '선택 완료',
                    style: textTheme.titleMedium?.copyWith(
                      color:
                          selectedTeam != null
                              ? Colors.white
                              : AppColors.gray50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }
}

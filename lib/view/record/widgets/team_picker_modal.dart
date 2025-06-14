import 'package:flutter/material.dart';
import 'package:seungyo/theme/theme.dart';
import 'package:seungyo/services/database_service.dart';
import 'package:seungyo/models/team.dart' as app_models;

class TeamPickerModal extends StatefulWidget {
  final String title;
  final String? selectedTeam;
  final Function(String) onTeamSelected;

  const TeamPickerModal({
    Key? key,
    required this.title,
    this.selectedTeam,
    required this.onTeamSelected,
  }) : super(key: key);

  @override
  State<TeamPickerModal> createState() => _TeamPickerModalState();
}

class _TeamPickerModalState extends State<TeamPickerModal> {
  String? _selectedTeam;
  List<app_models.Team> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedTeam = widget.selectedTeam;
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await DatabaseService().getTeamsAsAppModels();
      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading teams: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(colorScheme, textTheme),
          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
              : _buildTeamList(colorScheme, textTheme)
          ),
          if (!_isLoading) _buildConfirmButton(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title, style: textTheme.titleLarge),
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamList(ColorScheme colorScheme, TextTheme textTheme) {
    if (_teams.isEmpty) {
      return Center(
        child: Text(
          '팀이 없습니다.',
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _teams.length,
      itemBuilder: (context, index) {
        final team = _teams[index];
        final isSelected = _selectedTeam == team.id;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: team.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                team.logoUrl ?? '⚾',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          title: Text(
            team.name,
            style: textTheme.bodyLarge?.copyWith(
              color: isSelected ? AppColors.mint : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: isSelected ? Icon(Icons.check, color: AppColors.mint) : null,
          onTap: () {
            setState(() {
              _selectedTeam = team.id;
            });
          },
        );
      },
    );
  }

  Widget _buildConfirmButton(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _selectedTeam != null
              ? () {
                  widget.onTeamSelected(_selectedTeam!);
                  Navigator.pop(context);
                }
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
          child: Text(
            '선택 완료',
            style: AppTextStyles.button1.copyWith(
              color: _selectedTeam != null ? Colors.white : AppColors.gray50,
            ),
          ),
        ),
      ),
    );
  }
}

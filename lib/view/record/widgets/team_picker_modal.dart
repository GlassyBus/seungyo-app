import 'package:flutter/material.dart';
import 'package:seungyo/models/team.dart' as app_models;
import 'package:seungyo/theme/theme.dart';

class TeamPickerModal extends StatefulWidget {
  final String title;
  final String? selectedTeam;
  final Function(String) onTeamSelected;
  final List<app_models.Team> teams;

  const TeamPickerModal({
    super.key,
    required this.title,
    this.selectedTeam,
    required this.onTeamSelected,
    required this.teams,
  });

  @override
  State<TeamPickerModal> createState() => _TeamPickerModalState();
}

class _TeamPickerModalState extends State<TeamPickerModal> {
  String? _selectedTeam;

  @override
  void initState() {
    super.initState();
    _selectedTeam = widget.selectedTeam;
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
          Expanded(child: _buildTeamList(colorScheme, textTheme)),
          _buildConfirmButton(colorScheme, textTheme),
        ],
      ),
    );
  }

  /// 팀 로고 빌드
  Widget _buildTeamLogo(app_models.Team team) {
    if (team.logo != null && team.logo!.isNotEmpty) {
      if (team.logo!.startsWith('assets/')) {
        // Assets 이미지
        return Image.asset(
          team.logo!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            print('TeamPickerModal: Error loading team logo: ${team.logo}');
            return _buildFallbackLogo(team);
          },
        );
      } else {
        // 이모지나 다른 텍스트
        return Center(
          child: Text(team.logo!, style: const TextStyle(fontSize: 20)),
        );
      }
    } else {
      return _buildFallbackLogo(team);
    }
  }

  /// 대체 로고 (팀명 첫 글자 또는 기본 아이콘)
  Widget _buildFallbackLogo(app_models.Team team) {
    if (team.shortName.isNotEmpty) {
      return Center(
        child: Text(
          team.shortName.substring(0, 1),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
      );
    } else {
      return const Center(
        child: Icon(Icons.sports_baseball, size: 20, color: AppColors.navy),
      );
    }
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
    if (widget.teams.isEmpty) {
      return Center(
        child: Text(
          '팀이 없습니다.',
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.teams.length,
      itemBuilder: (context, index) {
        final team = widget.teams[index];
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
              color: AppColors.gray10,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gray20, width: 1),
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildTeamLogo(team),
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
          trailing:
              isSelected ? Icon(Icons.check, color: AppColors.mint) : null,
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
          onPressed:
              _selectedTeam != null
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

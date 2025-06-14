import 'package:flutter/material.dart';
import 'package:seungyo/theme/theme.dart';

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

  final List<Map<String, dynamic>> _teams = [
    {'name': 'KIA 타이거즈', 'logo': '🐅', 'color': Color(0xFFEA0029)},
    {'name': 'KT 위즈', 'logo': '🧙‍♂️', 'color': Color(0xFF000000)},
    {'name': 'LG 트윈스', 'logo': '⚾', 'color': Color(0xFFC30452)},
    {'name': 'NC 다이노스', 'logo': '🦕', 'color': Color(0xFF315288)},
    {'name': 'SSG 랜더스', 'logo': '⚡', 'color': Color(0xFFCE0E2D)},
    {'name': '두산 베어스', 'logo': '🐻', 'color': Color(0xFF131230)},
    {'name': '롯데 자이언츠', 'logo': '⚾', 'color': Color(0xFF041E42)},
    {'name': '삼성 라이온즈', 'logo': '🦁', 'color': Color(0xFF074CA1)},
    {'name': '키움 히어로즈', 'logo': '🦸‍♂️', 'color': Color(0xFF570514)},
    {'name': '한화 이글스', 'logo': '🦅', 'color': Color(0xFFFF6600)},
  ];

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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _teams.length,
      itemBuilder: (context, index) {
        final team = _teams[index];
        final isSelected = _selectedTeam == team['name'];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: team['color'],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(team['logo'], style: const TextStyle(fontSize: 20)),
            ),
          ),
          title: Text(
            team['name'],
            style: textTheme.bodyLarge?.copyWith(
              color: isSelected ? AppColors.mint : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing:
              isSelected ? Icon(Icons.check, color: AppColors.mint) : null,
          onTap: () {
            setState(() {
              _selectedTeam = team['name'];
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

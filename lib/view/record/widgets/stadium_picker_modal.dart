import 'package:flutter/material.dart';
import 'package:seungyo/models/stadium.dart' as app_models;
import 'package:seungyo/theme/theme.dart';

class StadiumPickerModal extends StatefulWidget {
  final String? selectedStadium;
  final Function(String) onStadiumSelected;
  final List<app_models.Stadium> stadiums;

  const StadiumPickerModal({
    super.key,
    this.selectedStadium,
    required this.onStadiumSelected,
    required this.stadiums,
  });

  @override
  State<StadiumPickerModal> createState() => _StadiumPickerModalState();
}

class _StadiumPickerModalState extends State<StadiumPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStadium;
  List<app_models.Stadium> _filteredStadiums = [];

  @override
  void initState() {
    super.initState();
    _selectedStadium = widget.selectedStadium;
    _filteredStadiums = widget.stadiums;
  }

  void _filterStadiums(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStadiums = widget.stadiums;
      } else {
        _filteredStadiums =
            widget.stadiums
                .where(
                  (stadium) =>
                      stadium.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          _buildSearchField(colorScheme, textTheme),
          Expanded(child: _buildStadiumList(colorScheme, textTheme)),
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
          Text('경기장 선택', style: textTheme.titleLarge),
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '경기장 검색',
          hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.gray50),
          prefixIcon: Icon(Icons.search, color: AppColors.gray50),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: textTheme.bodyMedium,
        onChanged: _filterStadiums,
      ),
    );
  }

  Widget _buildStadiumList(ColorScheme colorScheme, TextTheme textTheme) {
    if (_filteredStadiums.isEmpty) {
      return Center(
        child: Text(
          '경기장이 없습니다.',
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredStadiums.length,
      itemBuilder: (context, index) {
        final stadium = _filteredStadiums[index];
        final isSelected = _selectedStadium == stadium.id;

        return ListTile(
          title: Text(
            stadium.name,
            style: textTheme.bodyLarge?.copyWith(
              color: isSelected ? AppColors.mint : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            stadium.city,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
          ),
          trailing:
              isSelected ? Icon(Icons.check, color: AppColors.mint) : null,
          onTap: () {
            setState(() {
              _selectedStadium = stadium.id;
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
              _selectedStadium != null
                  ? () {
                    widget.onStadiumSelected(_selectedStadium!);
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
              color: _selectedStadium != null ? Colors.white : AppColors.gray50,
            ),
          ),
        ),
      ),
    );
  }
}

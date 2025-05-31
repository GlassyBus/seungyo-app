import 'package:flutter/material.dart';
import 'package:seungyo/theme/theme.dart';

class StadiumPickerModal extends StatefulWidget {
  final String? selectedStadium;
  final Function(String) onStadiumSelected;

  const StadiumPickerModal({
    Key? key,
    this.selectedStadium,
    required this.onStadiumSelected,
  }) : super(key: key);

  @override
  State<StadiumPickerModal> createState() => _StadiumPickerModalState();
}

class _StadiumPickerModalState extends State<StadiumPickerModal> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStadium;
  List<String> _filteredStadiums = [];

  final List<String> _stadiums = [
    '강릉종합운동장',
    '강화SSG퓨처스필드',
    '경남e스포츠상설경기장',
    '경민대학교 기념관',
    '경주축구공원',
    '계양체육관',
    '고양국가대표 아구훈련장',
    '고양소노아레나',
    '고척스카이돔',
    '광양종합운동장',
    '구미시민운동장',
    '군산시민운동장',
    '김천종합스포츠타운',
    '김포시민운동장',
    '나주종합운동장',
    '대구삼성라이온즈파크',
    '대전한화생명이글스파크',
    '동대문구민체육센터',
    '마산종합운동장',
    '목동야구장',
    '문학야구장',
    '부산아시아드주경기장',
    '부천종합운동장',
    '사직야구장',
    '상무야구장',
    '서울종합운동장',
    '성남종합운동장',
    '수원KT위즈파크',
    '수원월드컵경기장',
    '순천종합운동장',
    '신월야구장',
    '아산무궁화축구장',
    '안산와~스타디움',
    '안양종합운동장',
    '양주시민운동장',
    '여수종합운동장',
    '영천종합운동장',
    '울산문수월드컵경기장',
    '원주종합운동장',
    '의정부종합운동장',
    '이천종합운동장',
    '인천SSG랜더스필드',
    '인천아시아드주경기장',
    '잠실야구장',
    '전주월드컵경기장',
    '제주월드컵경기장',
    '창원NC파크',
    '천안종합운동장',
    '청주종합운동장',
    '춘천송암스포츠타운',
    '포항스틸야드',
    '한밭종합운동장',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStadium = widget.selectedStadium;
    _filteredStadiums = _stadiums;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStadiums(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStadiums = _stadiums;
      } else {
        _filteredStadiums =
            _stadiums
                .where(
                  (stadium) =>
                      stadium.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
      }
    });
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
    return ListView.builder(
      itemCount: _filteredStadiums.length,
      itemBuilder: (context, index) {
        final stadium = _filteredStadiums[index];
        final isSelected = _selectedStadium == stadium;

        return ListTile(
          title: Text(
            stadium,
            style: textTheme.bodyLarge?.copyWith(
              color: isSelected ? AppColors.mint : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing:
              isSelected ? Icon(Icons.check, color: AppColors.mint) : null,
          onTap: () {
            setState(() {
              _selectedStadium = stadium;
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

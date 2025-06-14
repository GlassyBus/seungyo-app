import 'package:flutter/material.dart';
import 'package:seungyo/mocks/mock_data.dart';
import 'package:seungyo/widgets/custom_checkbox.dart';
import 'package:seungyo/view/record/create_record_screen.dart';
import 'package:seungyo/widgets/custom_app_bar.dart';
import '../../models/game_record.dart';
import 'record_detail_screen.dart';
import 'widgets/game_record_card.dart';
// AppTextStyles 임포트 (CustomCheckbox에서 사용할 수 있도록)
import 'package:seungyo/theme/app_text_styles.dart';

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  bool _showOnlyFavorites = false;
  bool _isLoading = true;
  List<GameRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    final records = MockData.getGameRecords();
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  List<GameRecord> get _filteredRecords {
    return _showOnlyFavorites
        ? _records.where((record) => record.isFavorite).toList()
        : _records;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      body: _isLoading ? _buildLoadingState(context) : _buildContent(context),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // final textTheme = Theme.of(context).textTheme; // AppTextStyles 사용으로 변경
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            '기록을 불러오는 중...',
            style: AppTextStyles.body2.copyWith(
              color: colorScheme.outline,
            ), // AppTextStyles 사용
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        _buildFilterSection(context),
        Expanded(child: _buildRecordsList()),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        // Row로 감싸서 좌측 정렬
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomCheckbox(
            value: _showOnlyFavorites,
            label: '하트만 보기',
            onChanged: (value) {
              setState(() {
                _showOnlyFavorites = value;
              });
            },
            // CustomCheckbox 내부에서 AppTextStyles.body2 또는 적절한 스타일을 사용하도록 수정 필요
            // labelStyle: AppTextStyles.body2.copyWith(color: const Color(0xFF100F21)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_filteredRecords.isEmpty) {
      return _buildEmptyState();
    }
    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        itemCount: _filteredRecords.length,
        itemBuilder: (context, index) {
          final record = _filteredRecords[index];
          return Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: GameRecordCard(
              record: record,
              onTap: () => _navigateToDetail(record),
              onFavoriteToggle: () => _toggleFavorite(record),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    // final textTheme = Theme.of(context).textTheme; // AppTextStyles 사용으로 변경
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied_outlined,
            size: 60,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            _showOnlyFavorites ? '즐겨찾기한 기록이 없어요' : '아직 작성된 기록이 없어요',
            // AppTextStyles.subtitle1 또는 적절한 스타일 사용
            style: AppTextStyles.subtitle1.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(GameRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecordDetailPage(game: record)),
    );
  }

  void _toggleFavorite(GameRecord record) {
    setState(() {
      final index = _records.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _records[index] = record.copyWith(isFavorite: !record.isFavorite);
      }
    });
  }

  void _handleAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateRecordScreen(),
        fullscreenDialog: true,
      ),
    ).then((_) => _loadRecords());
  }
}

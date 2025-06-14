import 'package:flutter/material.dart';
import 'package:seungyo/theme/app_colors.dart';
import 'package:seungyo/theme/app_text_styles.dart';
import 'package:seungyo/view/record/create_record_screen.dart';
import 'package:seungyo/widgets/custom_app_bar.dart';
import '../../mocks/mock_data.dart';
import '../../models/game_record.dart';
import 'record_detail_screen.dart';
import 'widgets/game_record_card.dart';

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
    return _isLoading ? _buildLoadingState(context) : _buildContent(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            '기록을 불러오는 중...',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showOnlyFavorites = !_showOnlyFavorites;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    _showOnlyFavorites
                        ? colorScheme.primary
                        : colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color:
                      _showOnlyFavorites
                          ? colorScheme.primary
                          : colorScheme.outline,
                  width: 2,
                ),
              ),
              child:
                  _showOnlyFavorites
                      ? Icon(
                        Icons.check,
                        color: colorScheme.onPrimary,
                        size: 16,
                      )
                      : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '하트만 보기',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredRecords.length,
        itemBuilder: (context, index) {
          final record = _filteredRecords[index];
          return GameRecordCard(
            record: record,
            onTap: () => _navigateToDetail(record),
            onFavoriteToggle: () => _toggleFavorite(record),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_baseball_outlined,
            size: 80,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 24),
          Text(
            _showOnlyFavorites ? '즐겨찾기한 기록이 없습니다' : '아직 기록이 없습니다',
            style: textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _showOnlyFavorites
                ? '기록에 하트를 눌러 즐겨찾기에 추가해보세요!'
                : '상단의 + 버튼을 눌러 첫 기록을 추가해보세요!',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
            textAlign: TextAlign.center,
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
      MaterialPageRoute(builder: (context) => const CreateRecordScreen()),
    ).then((_) => _loadRecords());
  }
}

import 'package:flutter/material.dart';
import 'package:seungyo/theme/app_colors.dart';
import 'package:seungyo/theme/app_text_styles.dart';
import 'package:seungyo/view/record/create_record_screen.dart';
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
    return Scaffold(
      backgroundColor: AppColors.gray5,
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.gray5,
      elevation: 0,
      title: Text(
        '직관 기록',
        style: TextStyle(
          color: AppColors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.add, color: AppColors.black),
          onPressed: _handleAdd,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.navy),
          const SizedBox(height: 16),
          Text(
            '기록을 불러오는 중...',
            style: TextStyle(color: AppColors.gray70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [_buildFilterSection(), Expanded(child: _buildRecordsList())],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: AppColors.navy.withOpacity(0.3),
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
                color: _showOnlyFavorites ? AppColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _showOnlyFavorites ? AppColors.navy : AppColors.gray30,
                  width: 2,
                ),
              ),
              child:
                  _showOnlyFavorites
                      ? Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '하트만 보기',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 16,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_baseball_outlined,
            size: 80,
            color: AppColors.gray70,
          ),
          const SizedBox(height: 24),
          Text(
            _showOnlyFavorites ? '즐겨찾기한 기록이 없습니다' : '아직 기록이 없습니다',
            style: TextStyle(
              color: AppColors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _showOnlyFavorites
                ? '기록에 하트를 눌러 즐겨찾기에 추가해보세요!'
                : '우측 하단의 + 버튼을 눌러 첫 기록을 추가해보세요!',
            style: TextStyle(color: AppColors.gray70, fontSize: 16),
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

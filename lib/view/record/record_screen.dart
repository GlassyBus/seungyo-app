import 'package:flutter/material.dart';
import 'package:seungyo/view/record/create_record_screen.dart';
import 'package:seungyo/services/record_service.dart';

import '../../models/game_record.dart';
import 'record_detail_screen.dart';
import 'widgets/game_record_card.dart';

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> with WidgetsBindingObserver {
  bool _showOnlyFavorites = false;
  bool _isLoading = true;
  List<GameRecord> _records = [];
  final RecordService _recordService = RecordService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRecords();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 앱이 포그라운드로 돌아올 때 새로고침
    if (state == AppLifecycleState.resumed) {
      print('RecordScreen: App resumed, refreshing records...');
      _loadRecords();
    }
  }

  // 외부에서 새로고침을 위해 호출할 수 있는 public 메서드
  Future<void> refresh() async {
    await _loadRecords();
  }

  Future<void> _loadRecords() async {
    print('RecordScreen: Starting to load records...');
    setState(() {
      _isLoading = true;
    });

    try {
      print('RecordScreen: Calling RecordService.getAllRecords()...');
      final records = await _recordService.getAllRecords();
      print('RecordScreen: Loaded ${records.length} records from database');
      
      // 날짜 기준으로 내림차순 정렬 (최신 기록이 위로)
      records.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      print('RecordScreen: Records sorted by date (newest first)');
      
      for (int i = 0; i < records.length && i < 3; i++) {
        final record = records[i];
        print('RecordScreen: Record $i - ${record.homeTeam.name} vs ${record.awayTeam.name}, Date: ${record.dateTime}, Stadium: ${record.stadium.name}');
      }

      setState(() {
        _records = records;
        _isLoading = false;
      });
      
      print('RecordScreen: Records loaded and UI updated successfully');
    } catch (e) {
      print('RecordScreen: Error loading records: $e');
      print('RecordScreen: Error stack trace: ${StackTrace.current}');
      
      setState(() {
        _records = [];
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('기록을 불러오는 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<GameRecord> get _filteredRecords {
    final filtered = _showOnlyFavorites ? _records.where((record) => record.isFavorite).toList() : _records;
    print('RecordScreen: Filtered records count: ${filtered.length} (showOnlyFavorites: $_showOnlyFavorites)');
    return filtered;
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
          Text('기록을 불러오는 중...', style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(children: [_buildFilterSection(context), Expanded(child: _buildRecordsList())]);
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
                color: _showOnlyFavorites ? colorScheme.primary : colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _showOnlyFavorites ? colorScheme.primary : colorScheme.outline, width: 2),
              ),
              child: _showOnlyFavorites ? Icon(Icons.check, color: colorScheme.onPrimary, size: 16) : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '하트만 보기',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w500),
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
          Icon(Icons.sports_baseball_outlined, size: 80, color: colorScheme.outline),
          const SizedBox(height: 24),
          Text(
            _showOnlyFavorites ? '즐겨찾기한 기록이 없습니다' : '아직 기록이 없습니다',
            style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            _showOnlyFavorites ? '기록에 하트를 눌러 즐겨찾기에 추가해보세요!' : '상단의 + 버튼을 눌러 첫 기록을 추가해보세요!',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(GameRecord record) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => RecordDetailPage(game: record)));
  }

  Future<void> _toggleFavorite(GameRecord record) async {
    try {
      print('RecordScreen: Toggling favorite for record ID: ${record.id}');
      
      // RecordService를 통해 즐겨찾기 토글
      final success = await _recordService.toggleFavorite(record.id);
      
      if (success) {
        print('RecordScreen: Favorite toggled successfully');
        // UI 업데이트
        setState(() {
          final index = _records.indexWhere((r) => r.id == record.id);
          if (index != -1) {
            _records[index] = record.copyWith(isFavorite: !record.isFavorite);
          }
        });
      } else {
        print('RecordScreen: Failed to toggle favorite');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('즐겨찾기 변경에 실패했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('RecordScreen: Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('즐겨찾기 변경 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateRecordScreen()),
    ).then((result) {
      // 기록 추가 후 목록 새로고침
      if (result == true) {
        print('RecordScreen: Record added successfully, refreshing list...');
        _loadRecords();
      }
    });
  }
}

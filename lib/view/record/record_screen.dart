import 'package:flutter/material.dart';
import 'package:seungyo/services/record_service.dart';
import 'package:seungyo/theme/app_text_styles.dart';
import 'package:seungyo/view/record/create_record_screen.dart';

import '../../models/game_record.dart';
import 'record_detail_screen.dart';
import 'widgets/game_record_card.dart';

class RecordListPage extends StatefulWidget {
  final VoidCallback? onRecordChanged; // 기록 변경 콜백 추가

  const RecordListPage({super.key, this.onRecordChanged});

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
    if (state == AppLifecycleState.resumed) {
      print('RecordScreen: App resumed, refreshing records...');
      _loadRecords();
    }
  }

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

      // createdAt 기준으로 내림차순 정렬 (최신 기록이 위로)
      records.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      print('RecordScreen: Records sorted by createdAt (newest first)');

      for (int i = 0; i < records.length && i < 3; i++) {
        final record = records[i];
        print(
          'RecordScreen: Record $i - ${record.homeTeam.name} vs ${record.awayTeam.name}, Created: ${record.createdAt}, Stadium: ${record.stadium.name}',
        );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('기록을 불러오는 중 오류가 발생했습니다: $e'), backgroundColor: Colors.red));
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      body: _isLoading ? _buildLoadingState(context) : _buildContent(context),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text('기록을 불러오는 중...', style: AppTextStyles.body2.copyWith(color: colorScheme.outline)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(children: [_buildFilterSection(context), Expanded(child: _buildRecordsList())]);
  }

  Widget _buildFilterSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [_buildCustomCheckbox()]),
    );
  }

  Widget _buildCustomCheckbox() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showOnlyFavorites = !_showOnlyFavorites;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _showOnlyFavorites ? const Color(0xFF09004C) : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _showOnlyFavorites ? const Color(0xFF09004C) : const Color(0xFFE6EAF2),
                width: 2,
              ),
            ),
            child: _showOnlyFavorites ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
          ),
          const SizedBox(width: 8),
          Text('하트만 보기', style: AppTextStyles.body2.copyWith(color: const Color(0xFF100F21))),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied_outlined, size: 60, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            _showOnlyFavorites ? '즐겨찾기한 기록이 없어요' : '아직 작성된 기록이 없어요',
            style: AppTextStyles.subtitle1.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            _showOnlyFavorites ? '기록에 하트를 눌러 즐겨찾기에 추가해보세요!' : '상단의 + 버튼을 눌러 첫 기록을 추가해보세요!',
            style: AppTextStyles.body2.copyWith(color: colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(GameRecord record) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RecordDetailPage(game: record)),
    );

    // 상세 화면에서 변경사항이 있으면 리스트 새로고침
    if (result == true) {
      print('RecordScreen: Changes detected from detail page, refreshing list...');
      await _loadRecords();

      // 부모(메인 화면)에게 변경사항 알림
      if (widget.onRecordChanged != null) {
        widget.onRecordChanged!();
      }
    }
  }

  Future<void> _toggleFavorite(GameRecord record) async {
    try {
      print('RecordScreen: Toggling favorite for record ID: ${record.id}');

      final success = await _recordService.toggleFavorite(record.id);

      if (success) {
        print('RecordScreen: Favorite toggled successfully');
        setState(() {
          final index = _records.indexWhere((r) => r.id == record.id);
          if (index != -1) {
            _records[index] = record.copyWith(isFavorite: !record.isFavorite);
          }
        });

        // 부모(메인 화면)에게 변경사항 알림
        if (widget.onRecordChanged != null) {
          widget.onRecordChanged!();
        }
      } else {
        print('RecordScreen: Failed to toggle favorite');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('즐겨찾기 변경에 실패했습니다'), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      print('RecordScreen: Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('즐겨찾기 변경 중 오류가 발생했습니다: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _handleAdd() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRecordScreen())).then((result) {
      if (result == true) {
        print('RecordScreen: Record added successfully, refreshing list...');
        _loadRecords();
      }
    });
  }
}

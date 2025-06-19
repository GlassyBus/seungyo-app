import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/providers/schedule_provider.dart';
import 'package:seungyo/widgets/error_view.dart';
import 'package:seungyo/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../models/game_schedule.dart';
import '../../services/schedule_service.dart';
import '../../widgets/game_section_widget.dart';

import '../record/record_detail_screen.dart';
import '../record/create_record_screen.dart';
import 'widgets/calendar_header.dart';
import 'widgets/enhanced_calendar.dart';
import 'widgets/no_schedule_view.dart';
import 'widgets/record_item.dart';

/// 경기 일정 페이지
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleService _scheduleService = ScheduleService();
  List<GameSchedule> _selectedDateGames = [];
  bool _isLoadingGames = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ScheduleProvider>();
      provider.initialize();
      _loadSelectedDateGames(provider.selectedDate);
    });
  }

  /// 선택된 날짜의 경기 일정 로드
  Future<void> _loadSelectedDateGames(DateTime date) async {
    setState(() {
      _isLoadingGames = true;
    });

    try {
      final games = await _scheduleService.getSchedulesByDate(date);
      setState(() {
        _selectedDateGames = games;
        _isLoadingGames = false;
      });
    } catch (e) {
      setState(() {
        _selectedDateGames = [];
        _isLoadingGames = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingIndicator(message: '직관 기록을 불러오는 중...');
        }

        if (provider.hasError) {
          return ErrorView(
            message: provider.errorMessage,
            onRetry: provider.loadSchedules,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '경기 일정',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: AppColors.navy),
                onPressed: () {},
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: () async {
              await provider.loadSchedules();
              await _loadSelectedDateGames(provider.selectedDate);
            },
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  CalendarHeader(
                    currentMonth: provider.currentMonth,
                    onMonthChanged: provider.changeMonth,
                    onTodayPressed: provider.goToToday,
                  ),
                  EnhancedCalendar(
                    selectedDate: provider.selectedDate,
                    currentMonth: provider.currentMonth,
                    scheduleMap: provider.scheduleMap,
                    onDateSelected: (date) {
                      provider.selectDate(date);
                      _loadSelectedDateGames(date);
                    },
                    onMonthChanged: provider.changeMonth,
                  ),
                  const SizedBox(height: 16),
                  _buildSelectedDateHeader(provider.selectedDate),
                  
                  // 경기 일정 섹션 (메인과 동일한 컴포넌트 사용)
                  if (!_isLoadingGames && _selectedDateGames.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: GameSectionWidget(
                        title: '경기 일정',
                        games: _selectedDateGames,
                        attendedRecords: provider.daySchedules,
                        onGameTap: _handleGameTap,
                        emptyMessage: '경기가 없는 날이에요.',
                        padding: const EdgeInsets.all(0),
                      ),
                    ),
                  
                  // 직관 기록 섹션
                  _buildSelectedDateRecords(context, provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 경기 탭 처리 (메인과 동일한 로직)
  Future<void> _handleGameTap(GameSchedule game) async {
    // 해당 경기에 대한 기록이 이미 있는지 확인
    final provider = context.read<ScheduleProvider>();
    final existingRecord = provider.daySchedules.where((record) {
      final recordDate = record.dateTime;
      final gameDate = game.dateTime;

      return recordDate.year == gameDate.year &&
          recordDate.month == gameDate.month &&
          recordDate.day == gameDate.day &&
          record.homeTeam.name.contains(game.homeTeam) &&
          record.awayTeam.name.contains(game.awayTeam);
    }).firstOrNull;

    if (existingRecord != null) {
      // 기존 기록이 있으면 상세 화면으로
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecordDetailPage(game: existingRecord),
        ),
      );

      if (result == true) {
        provider.loadSchedules();
      }
    } else {
      // 기존 기록이 없으면 새 기록 작성 화면으로
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateRecordScreen(gameSchedule: game),
        ),
      );

      if (result == true) {
        provider.loadSchedules();
      }
    }
  }

  /// 선택된 날짜 헤더 위젯 생성
  Widget _buildSelectedDateHeader(DateTime selectedDate) {
    final formatter = DateFormat('yyyy. MM. dd(EEE)', 'ko_KR');
    final formattedDate = formatter.format(selectedDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        formattedDate,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 선택된 날짜의 직관 기록 위젯 생성
  Widget _buildSelectedDateRecords(
    BuildContext context,
    ScheduleProvider provider,
  ) {
    final selectedRecords = provider.daySchedules;

    if (selectedRecords.isEmpty && _selectedDateGames.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: NoScheduleView(
          isAllGamesCanceled: provider.isAllGamesCanceledOnSelectedDate,
          hasNoSchedule: !provider.isAllGamesCanceledOnSelectedDate,
        ),
      );
    }

    if (selectedRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 직관 기록 제목
        Container(
          padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
          child: Text(
            '직관 기록',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // 직관 기록 목록
        ...selectedRecords.map((record) {
          return RecordItem(
            record: record,
            onTap: () => _navigateToRecordDetail(context, record),
          );
        }).toList(),
      ],
    );
  }

  /// 직관 기록 상세 화면으로 이동
  void _navigateToRecordDetail(BuildContext context, dynamic record) async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecordDetailPage(game: record)),
      );

      // 상세 화면에서 변경이 있었다면 목록 새로고침
      if (result == true && mounted) {
        final provider = context.read<ScheduleProvider>();
        provider.loadSchedules();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    }
  }
}

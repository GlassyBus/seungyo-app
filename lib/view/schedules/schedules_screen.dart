import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/providers/schedule_provider.dart';
import 'package:seungyo/widgets/error_view.dart';
import 'package:seungyo/widgets/loading_indicator.dart';

import '../../models/game_schedule.dart';
import '../../services/schedule_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/game_section_widget.dart';
import '../record/create_record_screen.dart';
import '../record/record_detail_screen.dart';
import 'widgets/calendar_header.dart';
import 'widgets/enhanced_calendar.dart';
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

  @override
  void dispose() {
    super.dispose();
  }

  /// 선택된 날짜의 경기 일정 로드 (부분 로딩)
  Future<void> _loadSelectedDateGames(DateTime date) async {
    setState(() {
      _isLoadingGames = true;
      _selectedDateGames = []; // 기존 데이터 클리어
    });

    try {
      // 🚀 빠른 로딩: 먼저 캐시에서 확인하고 없으면 API 호출
      final games = await _scheduleService.getSchedulesByDate(date);

      // 직관 기록이 있는 경기를 우선으로 정렬
      final sortedGames = _sortGamesByRecord(games, date);

      setState(() {
        _selectedDateGames = sortedGames;
        _isLoadingGames = false;
      });
    } catch (e) {
      setState(() {
        _selectedDateGames = [];
        _isLoadingGames = false;
      });
    }
  }

  /// 직관 기록이 있는 경기를 우선으로 정렬
  List<GameSchedule> _sortGamesByRecord(
    List<GameSchedule> games,
    DateTime date,
  ) {
    final provider = context.read<ScheduleProvider>();
    final dateKey = DateTime(date.year, date.month, date.day);
    final dayRecords = provider.scheduleMap[dateKey] ?? [];

    final gamesWithRecord = <GameSchedule>[];
    final gamesWithoutRecord = <GameSchedule>[];

    for (final game in games) {
      final hasRecord = dayRecords.any((record) {
        // 팀 매칭 확인 (정규화된 이름으로)
        final recordHomeTeam = _normalizeTeamName(record.homeTeam.name);
        final recordAwayTeam = _normalizeTeamName(record.awayTeam.name);
        final gameHomeTeam = _normalizeTeamName(game.homeTeam);
        final gameAwayTeam = _normalizeTeamName(game.awayTeam);

        return (recordHomeTeam == gameHomeTeam && recordAwayTeam == gameAwayTeam) ||
            (recordHomeTeam == gameAwayTeam && recordAwayTeam == gameHomeTeam);
      });

      if (hasRecord) {
        gamesWithRecord.add(game);
      } else {
        gamesWithoutRecord.add(game);
      }
    }

    // 직관 기록이 있는 경기를 먼저, 그 다음에 없는 경기
    return [...gamesWithRecord, ...gamesWithoutRecord];
  }

  /// 팀 이름 정규화 (매칭 정확도 향상)
  String _normalizeTeamName(String teamName) {
    final teamMapping = {
      // 전체 이름 -> 짧은 이름
      'SSG 랜더스': 'SSG',
      '키움 히어로즈': '키움',
      'LG 트윈스': 'LG',
      'KIA 타이거즈': 'KIA',
      '한화 이글스': '한화',
      '삼성 라이온즈': '삼성',
      '두산 베어스': '두산',
      'KT 위즈': 'KT',
      'NC 다이노스': 'NC',
      '롯데 자이언츠': '롯데',
      
      // 이미 짧은 이름인 경우
      'SSG': 'SSG',
      '키움': '키움',
      'LG': 'LG',
      'KIA': 'KIA',
      '한화': '한화',
      '삼성': '삼성',
      '두산': '두산',
      'KT': 'KT',
      'NC': 'NC',
      '롯데': '롯데',
    };

    return teamMapping[teamName] ?? teamName;
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

                  // 직관 기록 섹션 (있을 때만 표시)
                  _buildSelectedDateRecords(context, provider),

                  // 경기 일정 섹션 (로딩 상태 표시)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: GameSectionWidget(
                      title: '',
                      // 제목 제거
                      games: _selectedDateGames,
                      attendedRecords: provider.daySchedules,
                      onGameTap: _handleGameTap,
                      emptyMessage: _isLoadingGames ? null : '경기가 없는 날이에요.',
                      padding: const EdgeInsets.all(0),
                      isLoading: _isLoadingGames, // 로딩 상태 전달
                    ),
                  ),
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
    final existingRecord =
        provider.daySchedules.where((record) {
          final recordDate = record.dateTime;
          final gameDate = game.dateTime;

          // 같은 날짜인지 확인
          final isSameDate = recordDate.year == gameDate.year &&
              recordDate.month == gameDate.month &&
              recordDate.day == gameDate.day;

          if (!isSameDate) return false;

          // 팀 매칭 확인 (정규화된 이름으로)
          final recordHomeTeam = _normalizeTeamName(record.homeTeam.name);
          final recordAwayTeam = _normalizeTeamName(record.awayTeam.name);
          final gameHomeTeam = _normalizeTeamName(game.homeTeam);
          final gameAwayTeam = _normalizeTeamName(game.awayTeam);

          return (recordHomeTeam == gameHomeTeam && recordAwayTeam == gameAwayTeam) ||
              (recordHomeTeam == gameAwayTeam && recordAwayTeam == gameHomeTeam);
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
        _loadSelectedDateGames(provider.selectedDate);
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
        _loadSelectedDateGames(provider.selectedDate);
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

    // 🚫 직관 기록이 없으면 아예 표시하지 않음
    if (selectedRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    // ✅ 직관 기록이 있을 때만 제목과 목록을 표시
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 직관 기록 제목 (있을 때만 표시)
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
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
        const SizedBox(height: 16), // 하단 여백
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
        _loadSelectedDateGames(provider.selectedDate);
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

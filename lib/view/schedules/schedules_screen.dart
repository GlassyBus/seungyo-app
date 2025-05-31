import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/providers/schedule_provider.dart';
import 'package:seungyo/services/record_service.dart';
import 'package:seungyo/theme/theme.dart';
import 'package:seungyo/widgets/error_view.dart';

import '../../models/game_schedule.dart';
import 'widgets/enhanced_calendar.dart';
import '../../widgets/loading_indicator.dart';
import '../record/record_detail_screen.dart';
import 'widgets/calendar_header.dart';
import 'widgets/no_schedule_view.dart';
import 'widgets/schedule_item.dart';

/// 경기 일정 페이지
class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  final RecordService _recordService = RecordService();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    // Provider 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().initialize();
    });
  }

  /// 애니메이션 초기화
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: _buildAppBar(context, provider),
          body: _buildBody(context, provider),
        );
      },
    );
  }

  /// 앱바 위젯 생성
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ScheduleProvider provider,
  ) {
    return AppBar(
      title: Text('경기 일정', style: Theme.of(context).textTheme.titleLarge),
      actions: [
        IconButton(
          icon: const Icon(Icons.today_outlined),
          onPressed: () {
            provider.goToToday();
            HapticFeedback.mediumImpact();
          },
          tooltip: '오늘로 이동',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            // TODO: 알림 설정 화면으로 이동
          },
          tooltip: '알림 설정',
        ),
      ],
    );
  }

  /// 본문 위젯 생성
  Widget _buildBody(BuildContext context, ScheduleProvider provider) {
    if (provider.isLoading) {
      return const LoadingIndicator(message: '경기 일정을 불러오는 중...');
    }

    if (provider.hasError) {
      return ErrorView(
        message: provider.errorMessage,
        onRetry: provider.loadSchedules,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.loadSchedules,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: FadeTransition(
          opacity: _fadeAnimation,
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
                onDateSelected: provider.selectDate,
                onMonthChanged: provider.changeMonth,
              ),
              SlideTransition(
                position: _slideAnimation,
                child: _buildSelectedDateSchedules(context, provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 선택된 날짜의 경기 일정 위젯 생성
  Widget _buildSelectedDateSchedules(
    BuildContext context,
    ScheduleProvider provider,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = DateFormat('yyyy. MM. dd(E)', 'ko_KR');
    final formattedDate = dateFormat.format(provider.selectedDate);

    return Column(
      children: [
        // 선택된 날짜 헤더
        _buildDateHeader(
          formattedDate,
          provider.daySchedules.length,
          textTheme,
        ),

        // 경기 일정 목록
        if (provider.daySchedules.isEmpty)
          _buildNoScheduleState(provider)
        else
          _buildScheduleList(provider.daySchedules, textTheme),

        const SizedBox(height: 100), // 하단 여백
      ],
    );
  }

  /// 날짜 헤더 위젯 생성
  Widget _buildDateHeader(
    String formattedDate,
    int scheduleCount,
    TextTheme textTheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navy.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              formattedDate,
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (scheduleCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${scheduleCount}경기',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 경기 일정 없음 상태 위젯 생성
  Widget _buildNoScheduleState(ScheduleProvider provider) {
    // 우천 취소인지 확인
    final dateKey = DateTime(
      provider.selectedDate.year,
      provider.selectedDate.month,
      provider.selectedDate.day,
    );
    final allDaySchedules = provider.scheduleMap[dateKey] ?? [];
    final isRainCanceled = allDaySchedules.any(
      (schedule) => schedule.status == GameStatus.canceled,
    );

    return NoScheduleView(isRainCanceled: isRainCanceled);
  }

  /// 경기 일정 목록 위젯 생성
  Widget _buildScheduleList(List<GameSchedule> schedules, TextTheme textTheme) {
    return Column(
      children:
          schedules.asMap().entries.map((entry) {
            final index = entry.key;
            final schedule = entry.value;
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 50)),
              curve: Curves.easeOutCubic,
              child: ScheduleItem(
                schedule: schedule,
                onTap:
                    schedule.hasAttended
                        ? () =>
                            _navigateToRecordDetail(schedule.attendedRecordId!)
                        : null,
              ),
            );
          }).toList(),
    );
  }

  /// 직관 기록 상세 페이지로 이동
  Future<void> _navigateToRecordDetail(int recordId) async {
    try {
      final allRecords = await _recordService.getAllRecords();
      final record = allRecords.firstWhere((r) => r.id == recordId);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecordDetailPage(game: record)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('기록을 찾을 수 없습니다')));
    }
  }
}

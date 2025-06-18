import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/providers/schedule_provider.dart';
import 'package:seungyo/widgets/error_view.dart';
import 'package:seungyo/widgets/loading_indicator.dart';

import '../record/record_detail_screen.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().initialize();
    });
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

        return RefreshIndicator(
          onRefresh: provider.loadSchedules,
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
                  onDateSelected: provider.selectDate,
                  onMonthChanged: provider.changeMonth,
                ),
                _buildSelectedDateRecords(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 선택된 날짜의 직관 기록 위젯 생성
  Widget _buildSelectedDateRecords(
    BuildContext context,
    ScheduleProvider provider,
  ) {
    final selectedRecords = provider.daySchedules;

    if (selectedRecords.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: NoScheduleView(isRainCanceled: false),
      );
    }

    return Column(
      children:
          selectedRecords.map((record) {
            return RecordItem(
              record: record,
              onTap: () => _navigateToRecordDetail(context, record),
            );
          }).toList(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }
}

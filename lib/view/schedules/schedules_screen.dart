import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seungyo/providers/schedule_provider.dart';
import 'package:seungyo/widgets/loading_indicator.dart';
import 'package:seungyo/widgets/error_view.dart';
import 'package:seungyo/widgets/custom_app_bar.dart';
import 'widgets/enhanced_calendar.dart';
import 'widgets/calendar_header.dart';
import 'widgets/no_schedule_view.dart';
import 'widgets/schedule_item.dart';

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
                _buildSelectedDateSchedules(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 선택된 날짜의 경기 일정 위젯 생성
  Widget _buildSelectedDateSchedules(
    BuildContext context,
    ScheduleProvider provider,
  ) {
    final selectedSchedules = provider.daySchedules;

    if (selectedSchedules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: NoScheduleView(isRainCanceled: false),
      );
    }

    return Column(
      children:
          selectedSchedules.map((schedule) {
            return ScheduleItem(
              schedule: schedule,
              onTap: () {
                // TODO: 경기 세부 정보 화면으로 이동
              },
            );
          }).toList(),
    );
  }
}

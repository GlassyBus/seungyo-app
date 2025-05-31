import 'package:flutter/material.dart';
import '../models/game_schedule.dart';
import '../services/schedule_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleService _scheduleService = ScheduleService();

  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  Map<DateTime, List<GameSchedule>> _scheduleMap = {};
  List<GameSchedule> _daySchedules = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Getters
  DateTime get selectedDate => _selectedDate;
  DateTime get currentMonth => _currentMonth;
  Map<DateTime, List<GameSchedule>> get scheduleMap => _scheduleMap;
  List<GameSchedule> get daySchedules => _daySchedules;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  /// 초기 데이터 로드
  Future<void> initialize() async {
    await loadSchedules();
  }

  /// 경기 일정 로드
  Future<void> loadSchedules() async {
    _setLoading(true);
    _clearError();

    try {
      // 직관 기록과 경기 일정 동기화
      await _scheduleService.syncWithRecords();

      // 현재 월의 경기 일정 로드
      final monthSchedules = await _scheduleService.getSchedulesByMonth(
        _currentMonth.year,
        _currentMonth.month,
      );

      // 선택된 날짜의 경기 일정 로드
      final daySchedules = await _scheduleService.getSchedulesByDate(
        _selectedDate,
      );

      // 날짜별 경기 일정 맵 생성
      final scheduleMap = _createScheduleMap(monthSchedules);

      _scheduleMap = scheduleMap;
      _daySchedules = daySchedules;
      _setLoading(false);
    } catch (e) {
      _setError('경기 일정을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 월 변경
  void changeMonth(int delta) {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    loadSchedules();
  }

  /// 날짜 선택
  void selectDate(DateTime date) {
    _selectedDate = date;
    loadSchedules();
  }

  /// 오늘 날짜로 이동
  void goToToday() {
    final today = DateTime.now();
    _selectedDate = today;
    _currentMonth = DateTime(today.year, today.month);
    loadSchedules();
  }

  /// 날짜별 경기 일정 맵 생성
  Map<DateTime, List<GameSchedule>> _createScheduleMap(
    List<GameSchedule> schedules,
  ) {
    final map = <DateTime, List<GameSchedule>>{};

    for (var schedule in schedules) {
      final date = DateTime(
        schedule.dateTime.year,
        schedule.dateTime.month,
        schedule.dateTime.day,
      );

      if (map.containsKey(date)) {
        map[date]!.add(schedule);
      } else {
        map[date] = [schedule];
      }
    }

    return map;
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 상태 설정
  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  /// 에러 상태 초기화
  void _clearError() {
    _hasError = false;
    _errorMessage = '';
  }
}

import 'package:flutter/material.dart';
import '../models/game_record.dart';
import '../models/game_schedule.dart';
import '../services/record_service.dart';
import '../services/schedule_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final RecordService _recordService = RecordService();
  final ScheduleService _scheduleService = ScheduleService();

  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  Map<DateTime, List<GameRecord>> _recordMap = {};
  Map<DateTime, List<GameSchedule>> _scheduleMap = {};
  List<GameRecord> _dayRecords = [];
  List<GameSchedule> _daySchedules = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Getters
  DateTime get selectedDate => _selectedDate;
  DateTime get currentMonth => _currentMonth;
  Map<DateTime, List<GameRecord>> get scheduleMap =>
      _recordMap; // 호환성을 위해 이름 유지
  List<GameRecord> get daySchedules => _dayRecords; // 호환성을 위해 이름 유지

  // 새로운 getter: 선택된 날짜의 모든 경기 (직관 기록 + 일정)
  List<dynamic> get allDayGames {
    final dateKey = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final records = _recordMap[dateKey] ?? [];
    final schedules = _scheduleMap[dateKey] ?? [];

    // 직관 기록이 있는 경기는 제외하고 일정만 추가
    final schedulesWithoutRecords =
        schedules.where((schedule) {
          return !records.any(
            (record) =>
                record.homeTeam.name == schedule.homeTeam &&
                record.awayTeam.name == schedule.awayTeam,
          );
        }).toList();

    // 직관 기록과 일정을 합쳐서 반환
    return [...records, ...schedulesWithoutRecords];
  }

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  /// 선택된 날짜에 모든 게임이 취소되었는지 확인
  bool get isAllGamesCanceledOnSelectedDate {
    final dateKey = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final allDayRecords = _recordMap[dateKey] ?? [];
    // 기록이 없으면 false 반환
    if (allDayRecords.isEmpty) return false;
    // 모든 기록이 취소되었는지 확인
    return allDayRecords.every((record) => record.canceled);
  }

  /// 초기 데이터 로드
  Future<void> initialize() async {
    await loadSchedules();
  }

  /// 직관 기록과 경기 일정 로드
  Future<void> loadSchedules() async {
    print('=== loadSchedules 시작 ===');
    _setLoading(true);
    _clearError();

    try {
      print('직관 기록과 경기 일정 로드 중...');

      // 직관 기록과 경기 일정을 동시에 로드
      final allRecords = await _recordService.getAllRecords();
      final allSchedules = await _scheduleService.getSchedulesByMonth(
        _currentMonth.year,
        _currentMonth.month,
      );

      print('로드된 직관 기록 수: ${allRecords.length}');
      print('로드된 경기 일정 수: ${allSchedules.length}');

      // 현재 월의 기록만 필터링
      final monthRecords =
          allRecords.where((record) {
            return record.gameDate.year == _currentMonth.year &&
                record.gameDate.month == _currentMonth.month;
          }).toList();

      // 날짜별 맵 생성
      _recordMap = _createRecordMap(monthRecords);
      _scheduleMap = _createScheduleMap(allSchedules);

      print('기록 맵 생성 완료: ${_recordMap.keys.length}개 날짜');
      print('일정 맵 생성 완료: ${_scheduleMap.keys.length}개 날짜');

      // 선택된 날짜의 기록 업데이트
      _updateDayRecords();
      print('선택된 날짜 전체 경기: ${allDayGames.length}개');

      _setLoading(false);
      print('=== loadSchedules 완료 ===');
    } catch (e) {
      print('에러 발생: $e');
      _setError('경기 일정을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  /// 월 변경
  void changeMonth(int delta) {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    // 월이 변경될 때만 데이터 로드
    loadSchedules();
  }

  /// 날짜 선택
  void selectDate(DateTime date) {
    _selectedDate = date;

    // 이미 로드된 데이터에서 해당 날짜의 기록만 필터링
    _updateDayRecords();
    notifyListeners();
  }

  /// 오늘 날짜로 이동
  void goToToday() {
    final today = DateTime.now();
    _selectedDate = today;
    _currentMonth = DateTime(today.year, today.month);
    loadSchedules();
  }

  /// 선택된 날짜의 기록 업데이트 (이미 로드된 데이터 활용)
  void _updateDayRecords() {
    final dateKey = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    // 해당 날짜의 기록에서 취소되지 않은 기록만 필터링
    final allDayRecords = _recordMap[dateKey] ?? [];
    _dayRecords = allDayRecords.where((record) => !record.canceled).toList();

    // 해당 날짜의 일정도 업데이트
    _daySchedules = _scheduleMap[dateKey] ?? [];

    print(
      '날짜 ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day} 기록: ${_dayRecords.length}개, 일정: ${_daySchedules.length}개',
    );
  }

  /// 날짜별 직관 기록 맵 생성
  Map<DateTime, List<GameRecord>> _createRecordMap(List<GameRecord> records) {
    final map = <DateTime, List<GameRecord>>{};

    for (var record in records) {
      final date = DateTime(
        record.gameDate.year,
        record.gameDate.month,
        record.gameDate.day,
      );

      if (map.containsKey(date)) {
        map[date]!.add(record);
      } else {
        map[date] = [record];
      }
    }

    return map;
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

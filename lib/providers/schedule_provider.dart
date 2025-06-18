import 'package:flutter/material.dart';
import '../models/game_record.dart';
import '../services/record_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final RecordService _recordService = RecordService();

  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  Map<DateTime, List<GameRecord>> _recordMap = {};
  List<GameRecord> _dayRecords = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Getters
  DateTime get selectedDate => _selectedDate;
  DateTime get currentMonth => _currentMonth;
  Map<DateTime, List<GameRecord>> get scheduleMap => _recordMap; // 호환성을 위해 이름 유지
  List<GameRecord> get daySchedules => _dayRecords; // 호환성을 위해 이름 유지
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  /// 초기 데이터 로드
  Future<void> initialize() async {
    await loadSchedules();
  }

  /// 직관 기록 로드 (기존 이름 유지하여 호환성 확보)
  Future<void> loadSchedules() async {
    print('=== loadSchedules 시작 ===');
    _setLoading(true);
    _clearError();

    try {
      print('직관 기록 로드 중...');
      
      // 모든 직관 기록 가져오기
      final allRecords = await _recordService.getAllRecords();
      print('로드된 직관 기록 수: ${allRecords.length}');

      // 현재 월의 기록만 필터링
      final monthRecords = allRecords.where((record) {
        return record.gameDate.year == _currentMonth.year &&
               record.gameDate.month == _currentMonth.month;
      }).toList();
      print('현재 월(${_currentMonth.year}년 ${_currentMonth.month}월) 기록: ${monthRecords.length}개');

      // 날짜별 기록 맵 생성
      _recordMap = _createRecordMap(monthRecords);
      print('기록 맵 생성 완료: ${_recordMap.keys.length}개 날짜');
      
      // 선택된 날짜의 기록 업데이트
      _updateDayRecords();
      print('선택된 날짜 기록: ${_dayRecords.length}개');
      
      _setLoading(false);
      print('=== loadSchedules 완료 ===');
    } catch (e) {
      print('에러 발생: $e');
      _setError('직관 기록을 불러오는 중 오류가 발생했습니다: $e');
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
    
    _dayRecords = _recordMap[dateKey] ?? [];
    print('날짜 ${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day} 기록: ${_dayRecords.length}개');
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
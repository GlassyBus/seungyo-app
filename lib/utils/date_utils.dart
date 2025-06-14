import 'package:intl/intl.dart';

/// 날짜 관련 유틸리티 클래스
final class AppDateUtils {
  const AppDateUtils._();
  
  /// 두 날짜가 같은 날인지 확인
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  /// 캘린더에 표시할 날짜 목록 생성
  static List<DateTime> generateCalendarDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final lastDayOfPrevMonth = DateTime(month.year, month.month, 0);
    
    final calendarDays = <DateTime>[];
    
    // 이전 달의 날짜들
    for (int i = 0; i < firstWeekday; i++) {
      calendarDays.add(
        DateTime(
          month.year, 
          month.month - 1, 
          lastDayOfPrevMonth.day - firstWeekday + i + 1,
        ),
      );
    }
    
    // 현재 달의 날짜들
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      calendarDays.add(DateTime(month.year, month.month, i));
    }
    
    // 다음 달의 날짜들 (6주 채우기)
    final remainingDays = 42 - calendarDays.length;
    for (int i = 1; i <= remainingDays; i++) {
      calendarDays.add(DateTime(month.year, month.month + 1, i));
    }
    
    return calendarDays;
  }
  
  /// 날짜를 yyyy-MM-dd 형식의 문자열로 변환
  static String formatDateToString(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// 문자열을 DateTime으로 변환
  static DateTime parseStringToDate(String dateString) {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }
  
  /// 두 날짜 사이의 일수 계산
  static int daysBetween(DateTime from, DateTime to) {
    final fromDate = DateTime(from.year, from.month, from.day);
    final toDate = DateTime(to.year, to.month, to.day);
    return toDate.difference(fromDate).inDays;
  }
  
  /// 주어진 월의 첫 날
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// 주어진 월의 마지막 날
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
  
  /// 한국어 요일 이름
  static String getKoreanWeekday(int weekday) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return weekdays[weekday % 7];
  }
  
  /// 한국어 날짜 포맷
  static String formatKoreanDate(DateTime date) {
    final formatter = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR');
    return formatter.format(date);
  }
  
  /// 시간 포맷
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}

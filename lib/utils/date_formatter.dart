import 'package:intl/intl.dart';

/// 날짜 포맷팅 유틸리티 클래스
class DateFormatter {
  DateFormatter._();

  static final DateFormat _dayOfWeekFormat = DateFormat('E', 'ko_KR');
  static final DateFormat _shortDateFormat = DateFormat('MM.dd', 'ko_KR');

  /// 전체 날짜 시간 포맷 (예: 2025.04.06(일) 14:00)
  static String formatFullDateTime(DateTime dateTime) {
    try {
      final formatter = DateFormat('yyyy.MM.dd(E) HH:mm', 'ko_KR');
      return formatter.format(dateTime);
    } catch (e) {
      // Fallback to simple format
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}(${_getFallbackDayOfWeek(dateTime)}) ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 날짜만 포맷 (예: 2024.03.15)
  static String formatDateOnly(DateTime dateTime) {
    try {
      final formatter = DateFormat('yyyy.MM.dd', 'ko_KR');
      return formatter.format(dateTime);
    } catch (e) {
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  /// 기본 날짜 포맷 (예: 2024.03.15)
  static String formatDate(DateTime dateTime) {
    return formatDateOnly(dateTime);
  }

  /// 간단한 날짜 포맷 (예: 3월 15일)
  static String formatSimpleDate(DateTime dateTime) {
    try {
      final formatter = DateFormat('M월 d일', 'ko_KR');
      return formatter.format(dateTime);
    } catch (e) {
      return '${dateTime.month}월 ${dateTime.day}일';
    }
  }

  /// 시간만 포맷 (예: 14:00)
  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 월년 포맷 (예: 2024년 03월)
  static String formatMonthYear(DateTime dateTime) {
    try {
      final formatter = DateFormat('yyyy년 MM월', 'ko_KR');
      return formatter.format(dateTime);
    } catch (e) {
      return '${dateTime.year}년 ${dateTime.month.toString().padLeft(2, '0')}월';
    }
  }

  /// 요일 포맷 (예: 금)
  static String formatDayOfWeek(DateTime dateTime) {
    try {
      return _dayOfWeekFormat.format(dateTime);
    } catch (e) {
      return _getFallbackDayOfWeek(dateTime);
    }
  }

  /// 짧은 날짜 포맷 (예: 03.15)
  static String formatShortDate(DateTime dateTime) {
    try {
      return _shortDateFormat.format(dateTime);
    } catch (e) {
      return '${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  /// 상대적 날짜 포맷 (예: 오늘, 어제, 내일)
  static String formatRelativeDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final difference = targetDate.difference(today).inDays;

    switch (difference) {
      case -1:
        return '어제';
      case 0:
        return '오늘';
      case 1:
        return '내일';
      default:
        return formatDateOnly(dateTime);
    }
  }

  static String _getFallbackDayOfWeek(DateTime dateTime) {
    const weekdays = [
      '월',
      '화',
      '수',
      '목',
      '금',
      '토',
      '일',
    ]; // Adjusted to match intl's weekday
    return weekdays[dateTime.weekday - 1];
  }
}

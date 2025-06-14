import '../models/game_schedule.dart';
import 'data/mock_schedules.dart';

/// Mock 데이터 제공자
abstract class MockDataProvider {
  /// 경기 일정 목록 가져오기
  static List<GameSchedule> getSchedules() => MockSchedules.schedules;

  /// 특정 팀의 경기 일정 가져오기
  static List<GameSchedule> getSchedulesByTeam(String teamName) {
    return MockSchedules.getByTeam(teamName);
  }

  /// 특정 날짜의 경기 일정 가져오기
  static List<GameSchedule> getSchedulesByDate(DateTime date) {
    return MockSchedules.getByDate(date);
  }
}

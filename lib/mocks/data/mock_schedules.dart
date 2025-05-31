import '../../models/game_schedule.dart';

/// Mock 경기 일정 데이터
abstract class MockSchedules {
  static final List<GameSchedule> schedules = _generateSchedules();

  /// 경기 일정 생성
  static List<GameSchedule> _generateSchedules() {
    const year = 2025;
    const month = 1;

    return [
      // 1월 5일 - SSG vs 키움 (종료)
      GameSchedule(
        id: 1,
        dateTime: DateTime(year, month, 5, 14, 0),
        stadium: '고척스카이돔',
        homeTeam: 'SSG',
        awayTeam: '키움',
        homeTeamLogo: '⚡',
        awayTeamLogo: '🦸‍♂️',
        status: GameStatus.finished,
        homeScore: 3,
        awayScore: 2,
        hasAttended: true,
        attendedRecordId: 1,
      ),

      // 1월 6일 - SSG vs 키움 (종료)
      GameSchedule(
        id: 2,
        dateTime: DateTime(year, month, 6, 14, 0),
        stadium: '고척스카이돔',
        homeTeam: 'SSG',
        awayTeam: '키움',
        homeTeamLogo: '⚡',
        awayTeamLogo: '🦸‍♂️',
        status: GameStatus.finished,
        homeScore: 0,
        awayScore: 1,
      ),

      // 1월 9일 - LG vs KIA (예정)
      GameSchedule(
        id: 5,
        dateTime: DateTime(year, month, 9, 17, 0),
        stadium: '잠실야구장',
        homeTeam: 'LG',
        awayTeam: 'KIA',
        homeTeamLogo: '⚾',
        awayTeamLogo: '🐅',
        status: GameStatus.scheduled,
      ),

      // 1월 12일 - 두산 vs 삼성 (진행중)
      GameSchedule(
        id: 8,
        dateTime: DateTime(year, month, 12, 14, 0),
        stadium: '잠실야구장',
        homeTeam: '두산',
        awayTeam: '삼성',
        homeTeamLogo: '🐻',
        awayTeamLogo: '🦁',
        status: GameStatus.inProgress,
        homeScore: 2,
        awayScore: 1,
      ),

      // 1월 15일 - KT vs 한화 (예정)
      GameSchedule(
        id: 9,
        dateTime: DateTime(year, month, 15, 18, 30),
        stadium: '수원KT위즈파크',
        homeTeam: 'KT',
        awayTeam: '한화',
        homeTeamLogo: '🧙‍♂️',
        awayTeamLogo: '🦅',
        status: GameStatus.scheduled,
      ),
    ];
  }

  /// 특정 팀의 경기 일정 필터링
  static List<GameSchedule> getByTeam(String teamName) {
    return schedules
        .where(
          (schedule) =>
              schedule.homeTeam == teamName || schedule.awayTeam == teamName,
        )
        .toList();
  }

  /// 특정 상태의 경기 일정 필터링
  static List<GameSchedule> getByStatus(GameStatus status) {
    return schedules.where((schedule) => schedule.status == status).toList();
  }

  /// 특정 날짜의 경기 일정 필터링
  static List<GameSchedule> getByDate(DateTime date) {
    return schedules
        .where(
          (schedule) =>
              schedule.dateTime.year == date.year &&
              schedule.dateTime.month == date.month &&
              schedule.dateTime.day == date.day,
        )
        .toList();
  }
}

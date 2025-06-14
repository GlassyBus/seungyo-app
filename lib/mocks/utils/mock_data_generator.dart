import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/game_schedule.dart';
import '../../models/game_record.dart';
import '../../models/stadium.dart';
import '../../models/team.dart';
import '../data/mock_teams.dart';
import '../data/mock_stadiums.dart';

/// Mock 데이터 생성 유틸리티
abstract class MockDataGenerator {
  static final Random _random = Random();

  /// 랜덤 경기 일정 생성
  static GameSchedule generateRandomSchedule({
    required int id,
    required DateTime dateTime,
    String? homeTeam,
    String? awayTeam,
    String? stadium,
  }) {
    final teams = MockTeams.teams;
    final stadiums = MockStadiums.stadiums;

    final selectedHomeTeam =
        homeTeam ?? teams[_random.nextInt(teams.length)].name;
    final availableAwayTeams =
        teams.where((team) => team.name != selectedHomeTeam).toList();
    final selectedAwayTeam =
        awayTeam ??
        availableAwayTeams[_random.nextInt(availableAwayTeams.length)].name;

    final selectedStadium =
        stadium ?? stadiums[_random.nextInt(stadiums.length)].name;

    final status = GameStatus.values[_random.nextInt(GameStatus.values.length)];

    int? homeScore;
    int? awayScore;
    if (status == GameStatus.finished) {
      homeScore = _random.nextInt(10);
      awayScore = _random.nextInt(10);
    }

    return GameSchedule(
      id: id,
      dateTime: dateTime,
      stadium: selectedStadium,
      homeTeam: selectedHomeTeam,
      awayTeam: selectedAwayTeam,
      homeTeamLogo: MockTeams.findByName(selectedHomeTeam)?.logo ?? '⚾',
      awayTeamLogo: MockTeams.findByName(selectedAwayTeam)?.logo ?? '⚾',
      status: status,
      homeScore: homeScore,
      awayScore: awayScore,
      hasAttended: _random.nextBool(),
    );
  }

  /// 월별 경기 일정 생성
  static List<GameSchedule> generateMonthlySchedules(
    int year,
    int month, {
    int gamesPerWeek = 3,
  }) {
    final schedules = <GameSchedule>[];
    final daysInMonth = DateTime(year, month + 1, 0).day;

    int scheduleId = 1;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);

      // 주말에 더 많은 경기 배치
      final isWeekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      final gameCount =
          isWeekend
              ? _random.nextInt(3) + 1
              : // 1-3경기
              _random.nextInt(2); // 0-1경기

      for (int i = 0; i < gameCount; i++) {
        final gameTime = DateTime(
          year,
          month,
          day,
          14 + (i * 3), // 14시, 17시, 20시
        );

        schedules.add(
          generateRandomSchedule(id: scheduleId++, dateTime: gameTime),
        );
      }
    }

    return schedules;
  }

  /// 결과 판정 헬퍼 메서드
  static GameResult _determineResult(
    int homeScore,
    int awayScore,
    String myTeam,
    String homeTeam,
  ) {
    if (homeScore == awayScore) return GameResult.draw;
    final myTeamWon =
        (myTeam == homeTeam && homeScore > awayScore) ||
        (myTeam != homeTeam && awayScore > homeScore);
    return myTeamWon ? GameResult.win : GameResult.lose;
  }

  /// 랜덤 게임 기록 생성
  static GameRecord generateRandomRecord({
    required int id,
    required GameSchedule schedule,
    required String myTeam,
  }) {
    final seatSections = ['1루측 내야', '3루측 내야', '외야석', '응원석'];
    final weathers = ['맑음', '흐림', '비', '눈'];

    final stadium =
        MockStadiums.findByName(schedule.stadium) ??
        const Stadium(id: 'unknown', name: '알 수 없는 구장', city: '알 수 없음');
    final homeTeam =
        MockTeams.findByName(schedule.homeTeam) ??
        const Team(
          id: 'unknown',
          name: '알 수 없는 팀',
          shortName: '???',
          primaryColor: Color(0xFF000000),
          secondaryColor: Color(0xFFFFFFFF),
        );
    final awayTeam =
        MockTeams.findByName(schedule.awayTeam) ??
        const Team(
          id: 'unknown',
          name: '알 수 없는 팀',
          shortName: '???',
          primaryColor: Color(0xFF000000),
          secondaryColor: Color(0xFFFFFFFF),
        );
    final myTeamObj = MockTeams.findByName(myTeam);

    return GameRecord(
      id: id,
      scheduleId: schedule.id,
      dateTime: schedule.dateTime,
      stadium: stadium,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeScore: schedule.homeScore ?? 0,
      awayScore: schedule.awayScore ?? 0,
      myTeam: myTeamObj,
      seatSection: seatSections[_random.nextInt(seatSections.length)],
      seatNumber: '${_random.nextInt(20) + 1}열 ${_random.nextInt(30) + 1}번',
      weather: weathers[_random.nextInt(weathers.length)],
      temperature: 10.0 + _random.nextDouble() * 20, // 10-30도
      rating: 1.0 + _random.nextDouble() * 4, // 1-5점
      foodRating: 1.0 + _random.nextDouble() * 4,
      atmosphereRating: 1.0 + _random.nextDouble() * 4,
      ticketPrice: 15000 + _random.nextInt(35000), // 15,000-50,000원
      totalCost: 25000 + _random.nextInt(75000), // 25,000-100,000원
      memo: '즐거운 경기였습니다!',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      result: _determineResult(
        schedule.homeScore ?? 0,
        schedule.awayScore ?? 0,
        myTeam,
        schedule.homeTeam,
      ),
    );
  }
}

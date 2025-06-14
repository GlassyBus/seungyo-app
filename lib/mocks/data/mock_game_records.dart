import '../../models/game_record.dart';
import '../../models/stadium.dart';
import '../../models/team.dart';
import 'package:flutter/material.dart';

/// Mock 게임 기록 데이터
abstract class MockGameRecords {
  static final List<GameRecord> records = [
    GameRecord(
      id: 1,
      scheduleId: 1,
      dateTime: DateTime(2025, 1, 5, 14, 0),
      stadium: const Stadium(id: 'ssg', name: '고척스카이돔', city: '서울'),
      homeTeam: const Team(
        id: 'ssg',
        name: 'SSG 랜더스',
        shortName: 'SSG',
        primaryColor: Color(0xFFCE0E2D),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      awayTeam: const Team(
        id: 'kiwoom',
        name: '키움 히어로즈',
        shortName: '키움',
        primaryColor: Color(0xFF820024),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      homeScore: 3,
      awayScore: 2,
      myTeam: const Team(
        id: 'ssg',
        name: 'SSG 랜더스',
        shortName: 'SSG',
        primaryColor: Color(0xFFCE0E2D),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      seatSection: '1루측 내야',
      seatNumber: 'A구역 15열 23번',
      weather: '맑음',
      temperature: 15.5,
      photos: [
        '/assets/images/game1_photo1.jpg',
        '/assets/images/game1_photo2.jpg',
      ],
      memo: '시즌 첫 경기! 짜릿한 승리였다. 9회말 역전승이 정말 감동적이었음.',
      rating: 4.5,
      foodRating: 4.0,
      atmosphereRating: 5.0,
      ticketPrice: 25000,
      totalCost: 45000,
      companions: ['친구1', '친구2'],
      highlights: ['9회말 역전 홈런', '완벽한 날씨', '맛있는 치킨'],
      createdAt: DateTime(2025, 1, 5, 18, 30),
      updatedAt: DateTime(2025, 1, 5, 18, 30),
      result: GameResult.win,
    ),
    GameRecord(
      id: 2,
      scheduleId: 3,
      dateTime: DateTime(2025, 1, 7, 14, 0),
      stadium: const Stadium(id: 'ssg', name: '고척스카이돔', city: '서울'),
      homeTeam: const Team(
        id: 'ssg',
        name: 'SSG 랜더스',
        shortName: 'SSG',
        primaryColor: Color(0xFFCE0E2D),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      awayTeam: const Team(
        id: 'kiwoom',
        name: '키움 히어로즈',
        shortName: '키움',
        primaryColor: Color(0xFF820024),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      homeScore: 5,
      awayScore: 2,
      myTeam: const Team(
        id: 'ssg',
        name: 'SSG 랜더스',
        shortName: 'SSG',
        primaryColor: Color(0xFFCE0E2D),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      seatSection: '외야석',
      seatNumber: '외야 응원석 5열 10번',
      weather: '흐림',
      temperature: 12.0,
      photos: ['/assets/images/game2_photo1.jpg'],
      memo: '응원석에서 본 경기. 분위기가 정말 좋았다!',
      rating: 4.0,
      foodRating: 3.5,
      atmosphereRating: 4.5,
      ticketPrice: 15000,
      totalCost: 30000,
      companions: ['가족'],
      highlights: ['대량득점', '응원가 합창', '선수 사인'],
      createdAt: DateTime(2025, 1, 7, 17, 45),
      updatedAt: DateTime(2025, 1, 7, 17, 45),
      result: GameResult.win,
    ),
  ];

  /// 특정 팀의 기록 필터링
  static List<GameRecord> getByTeam(String teamName) {
    return records.where((record) => record.myTeam == teamName).toList();
  }

  /// 특정 결과의 기록 필터링
  static List<GameRecord> getByResult(GameResult result) {
    return records.where((record) => record.result == result).toList();
  }

  /// 특정 구장의 기록 필터링
  static List<GameRecord> getByStadium(String stadiumName) {
    return records.where((record) => record.stadium == stadiumName).toList();
  }

  /// 평점별 기록 필터링
  static List<GameRecord> getByRating(double minRating) {
    return records
        .where((record) => (record.rating ?? 0) >= minRating)
        .toList();
  }

  /// 최근 기록 가져오기
  static List<GameRecord> getRecent(int count) {
    final sortedRecords = List<GameRecord>.from(records)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return sortedRecords.take(count).toList();
  }

  /// 통계 계산
  static Map<String, dynamic> getStatistics() {
    final totalGames = records.length;
    final wins = records.where((r) => r.result == GameResult.win).length;
    final losses = records.where((r) => r.result == GameResult.lose).length;
    final draws = records.where((r) => r.result == GameResult.draw).length;

    final totalCost = records
        .map((r) => r.totalCost ?? 0)
        .fold(0, (sum, cost) => sum + cost);

    final averageRating =
        records
            .where((r) => r.rating != null)
            .map((r) => r.rating!)
            .fold(0.0, (sum, rating) => sum + rating) /
        records.where((r) => r.rating != null).length;

    return {
      'totalGames': totalGames,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'winRate': totalGames > 0 ? wins / totalGames : 0.0,
      'totalCost': totalCost,
      'averageCost': totalGames > 0 ? totalCost / totalGames : 0,
      'averageRating': averageRating.isNaN ? 0.0 : averageRating,
    };
  }
}

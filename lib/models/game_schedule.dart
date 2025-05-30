import 'package:equatable/equatable.dart';

/// 게임 상태 열거형
enum GameStatus {
  scheduled('예정'),
  inProgress('진행중'),
  finished('종료'),
  postponed('연기'),
  canceled('취소');

  const GameStatus(this.displayName);
  final String displayName;
}

/// 경기 일정 엔티티
class GameSchedule extends Equatable {
  const GameSchedule({
    required this.id,
    required this.dateTime,
    required this.stadium,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamLogo,
    this.awayTeamLogo,
    this.homeScore,
    this.awayScore,
    required this.status,
    this.hasAttended = false,
    this.attendedRecordId,
  });

  final int id;
  final DateTime dateTime;
  final String stadium;
  final String homeTeam;
  final String awayTeam;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final int? homeScore;
  final int? awayScore;
  final GameStatus status;
  final bool hasAttended;
  final int? attendedRecordId;

  /// 게임 날짜 (시간 제외)
  DateTime get gameDate =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  /// 복사본 생성
  GameSchedule copyWith({
    int? id,
    DateTime? dateTime,
    String? stadium,
    String? homeTeam,
    String? awayTeam,
    String? homeTeamLogo,
    String? awayTeamLogo,
    int? homeScore,
    int? awayScore,
    GameStatus? status,
    bool? hasAttended,
    int? attendedRecordId,
  }) {
    return GameSchedule(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      stadium: stadium ?? this.stadium,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeTeamLogo: homeTeamLogo ?? this.homeTeamLogo,
      awayTeamLogo: awayTeamLogo ?? this.awayTeamLogo,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      status: status ?? this.status,
      hasAttended: hasAttended ?? this.hasAttended,
      attendedRecordId: attendedRecordId ?? this.attendedRecordId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        dateTime,
        stadium,
        homeTeam,
        awayTeam,
        homeTeamLogo,
        awayTeamLogo,
        homeScore,
        awayScore,
        status,
        hasAttended,
        attendedRecordId,
      ];
}

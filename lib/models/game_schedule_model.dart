import 'game_schedule.dart';

/// 경기 일정 데이터 모델
class GameScheduleModel {
  const GameScheduleModel({
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

  /// JSON에서 생성
  factory GameScheduleModel.fromJson(Map<String, dynamic> json) {
    return GameScheduleModel(
      id: json['id'] as int,
      dateTime: DateTime.parse(json['dateTime'] as String),
      stadium: json['stadium'] as String,
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      homeTeamLogo: json['homeTeamLogo'] as String?,
      awayTeamLogo: json['awayTeamLogo'] as String?,
      homeScore: json['homeScore'] as int?,
      awayScore: json['awayScore'] as int?,
      status: GameStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GameStatus.scheduled,
      ),
      hasAttended: json['hasAttended'] as bool? ?? false,
      attendedRecordId: json['attendedRecordId'] as int?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'stadium': stadium,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeTeamLogo': homeTeamLogo,
      'awayTeamLogo': awayTeamLogo,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'status': status.name,
      'hasAttended': hasAttended,
      'attendedRecordId': attendedRecordId,
    };
  }

  /// 엔티티로 변환
  GameSchedule toEntity() {
    return GameSchedule(
      id: id,
      dateTime: dateTime,
      stadium: stadium,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeTeamLogo: homeTeamLogo,
      awayTeamLogo: awayTeamLogo,
      homeScore: homeScore,
      awayScore: awayScore,
      status: status,
      hasAttended: hasAttended,
      attendedRecordId: attendedRecordId,
    );
  }

  /// 엔티티에서 생성
  factory GameScheduleModel.fromEntity(GameSchedule entity) {
    return GameScheduleModel(
      id: entity.id,
      dateTime: entity.dateTime,
      stadium: entity.stadium,
      homeTeam: entity.homeTeam,
      awayTeam: entity.awayTeam,
      homeTeamLogo: entity.homeTeamLogo,
      awayTeamLogo: entity.awayTeamLogo,
      homeScore: entity.homeScore,
      awayScore: entity.awayScore,
      status: entity.status,
      hasAttended: entity.hasAttended,
      attendedRecordId: entity.attendedRecordId,
    );
  }
}

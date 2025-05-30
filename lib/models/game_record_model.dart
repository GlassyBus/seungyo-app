import 'game_record.dart';
import 'team_model.dart';
import 'stadium_model.dart';

/// 게임 기록 데이터 모델
class GameRecordModel {
  const GameRecordModel({
    required this.id,
    required this.dateTime,
    required this.stadium,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.result,
    this.seatInfo,
    this.weather = '',
    this.companions = const [],
    this.photos = const [],
    this.memo = '',
    this.imageUrl,
    this.isFavorite = false,
  });

  final int id;
  final DateTime dateTime;
  final StadiumModel stadium;
  final TeamModel homeTeam;
  final TeamModel awayTeam;
  final int homeScore;
  final int awayScore;
  final GameResult result;
  final String? seatInfo;
  final String weather;
  final List<String> companions;
  final List<String> photos;
  final String memo;
  final String? imageUrl;
  final bool isFavorite;

  /// JSON에서 생성
  factory GameRecordModel.fromJson(Map<String, dynamic> json) {
    return GameRecordModel(
      id: json['id'] as int,
      dateTime: DateTime.parse(json['dateTime'] as String),
      stadium: StadiumModel.fromJson(json['stadium'] as Map<String, dynamic>),
      homeTeam: TeamModel.fromJson(json['homeTeam'] as Map<String, dynamic>),
      awayTeam: TeamModel.fromJson(json['awayTeam'] as Map<String, dynamic>),
      homeScore: json['homeScore'] as int,
      awayScore: json['awayScore'] as int,
      result: GameResult.values.firstWhere(
        (e) => e.name == json['result'],
        orElse: () => GameResult.draw,
      ),
      seatInfo: json['seatInfo'] as String?,
      weather: json['weather'] as String? ?? '',
      companions: List<String>.from(json['companions'] as List? ?? []),
      photos: List<String>.from(json['photos'] as List? ?? []),
      memo: json['memo'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'stadium': stadium.toJson(),
      'homeTeam': homeTeam.toJson(),
      'awayTeam': awayTeam.toJson(),
      'homeScore': homeScore,
      'awayScore': awayScore,
      'result': result.name,
      'seatInfo': seatInfo,
      'weather': weather,
      'companions': companions,
      'photos': photos,
      'memo': memo,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
    };
  }

  /// 엔티티로 변환
  GameRecord toEntity() {
    return GameRecord(
      id: id,
      dateTime: dateTime,
      stadium: stadium.toEntity(),
      homeTeam: homeTeam.toEntity(),
      awayTeam: awayTeam.toEntity(),
      homeScore: homeScore,
      awayScore: awayScore,
      result: result,
      seatInfo: seatInfo,
      weather: weather,
      companions: companions,
      photos: photos,
      memo: memo,
      imageUrl: imageUrl,
      isFavorite: isFavorite,
    );
  }

  /// 엔티티에서 생성
  factory GameRecordModel.fromEntity(GameRecord entity) {
    return GameRecordModel(
      id: entity.id,
      dateTime: entity.dateTime,
      stadium: StadiumModel.fromEntity(entity.stadium),
      homeTeam: TeamModel.fromEntity(entity.homeTeam),
      awayTeam: TeamModel.fromEntity(entity.awayTeam),
      homeScore: entity.homeScore,
      awayScore: entity.awayScore,
      result: entity.result,
      seatInfo: entity.seatInfo,
      weather: entity.weather,
      companions: entity.companions,
      photos: entity.photos,
      memo: entity.memo,
      imageUrl: entity.imageUrl,
      isFavorite: entity.isFavorite,
    );
  }
}

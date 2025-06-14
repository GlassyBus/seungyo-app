import 'package:equatable/equatable.dart';
import 'team.dart';
import 'stadium.dart';

/// 게임 결과 열거형
enum GameResult {
  win('승리'),
  lose('패배'),
  draw('무승부');

  const GameResult(this.displayName);
  final String displayName;
}

/// 게임 기록 엔티티
class GameRecord extends Equatable {
  const GameRecord({
    required this.id,
    this.scheduleId,
    required this.dateTime,
    required this.stadium,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    this.myTeam,
    this.seatSection,
    this.seatNumber,
    this.temperature,
    this.rating,
    this.foodRating,
    this.atmosphereRating,
    this.ticketPrice,
    this.totalCost,
    this.highlights,
    this.createdAt,
    this.updatedAt,
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
  final int? scheduleId;
  final DateTime dateTime;
  final Stadium stadium;
  final Team homeTeam;
  final Team awayTeam;
  final Team? myTeam;
  final int homeScore;
  final int awayScore;
  final String? seatSection;
  final String? seatNumber;
  final double? temperature;
  final double? rating;
  final double? foodRating;
  final double? atmosphereRating;
  final int? ticketPrice;
  final int? totalCost;
  final List<String>? highlights;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final GameResult result;
  final String? seatInfo;
  final String weather;
  final List<String> companions;
  final List<String> photos;
  final String memo;
  final String? imageUrl;
  final bool isFavorite;

  /// 경기 날짜 (시간 제외)
  DateTime get gameDate =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  /// JSON으로부터 GameRecord 객체 생성
  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'],
      scheduleId: json['scheduleId'],
      dateTime: DateTime.parse(json['dateTime']),
      stadium: Stadium.fromJson(json['stadium']),
      homeTeam: Team.fromJson(json['homeTeam']),
      awayTeam: Team.fromJson(json['awayTeam']),
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      myTeam: json['myTeam'] != null ? Team.fromJson(json['myTeam']) : null,
      seatSection: json['seatSection'],
      seatNumber: json['seatNumber'],
      temperature: json['temperature']?.toDouble(),
      rating: json['rating']?.toDouble(),
      foodRating: json['foodRating']?.toDouble(),
      atmosphereRating: json['atmosphereRating']?.toDouble(),
      ticketPrice: json['ticketPrice'],
      totalCost: json['totalCost'],
      highlights: json['highlights']?.cast<String>(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      result: GameResult.values.firstWhere((e) => e.name == json['result']),
      seatInfo: json['seatInfo'],
      weather: json['weather'] ?? '',
      companions: json['companions']?.cast<String>() ?? [],
      photos: json['photos']?.cast<String>() ?? [],
      memo: json['memo'] ?? '',
      imageUrl: json['imageUrl'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  /// GameRecord 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'dateTime': dateTime.toIso8601String(),
      'stadium': stadium.toJson(),
      'homeTeam': homeTeam.toJson(),
      'awayTeam': awayTeam.toJson(),
      'homeScore': homeScore,
      'awayScore': awayScore,
      'myTeam': myTeam?.toJson(),
      'seatSection': seatSection,
      'seatNumber': seatNumber,
      'temperature': temperature,
      'rating': rating,
      'foodRating': foodRating,
      'atmosphereRating': atmosphereRating,
      'ticketPrice': ticketPrice,
      'totalCost': totalCost,
      'highlights': highlights,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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

  /// 객체 복사 메서드
  GameRecord copyWith({
    int? id,
    int? scheduleId,
    DateTime? dateTime,
    Stadium? stadium,
    Team? homeTeam,
    Team? awayTeam,
    Team? myTeam,
    int? homeScore,
    int? awayScore,
    String? seatSection,
    String? seatNumber,
    double? temperature,
    double? rating,
    double? foodRating,
    double? atmosphereRating,
    int? ticketPrice,
    int? totalCost,
    List<String>? highlights,
    DateTime? createdAt,
    DateTime? updatedAt,
    GameResult? result,
    String? seatInfo,
    String? weather,
    List<String>? companions,
    List<String>? photos,
    String? memo,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return GameRecord(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      dateTime: dateTime ?? this.dateTime,
      stadium: stadium ?? this.stadium,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      myTeam: myTeam ?? this.myTeam,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      seatSection: seatSection ?? this.seatSection,
      seatNumber: seatNumber ?? this.seatNumber,
      temperature: temperature ?? this.temperature,
      rating: rating ?? this.rating,
      foodRating: foodRating ?? this.foodRating,
      atmosphereRating: atmosphereRating ?? this.atmosphereRating,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      totalCost: totalCost ?? this.totalCost,
      highlights: highlights ?? this.highlights,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      result: result ?? this.result,
      seatInfo: seatInfo ?? this.seatInfo,
      weather: weather ?? this.weather,
      companions: companions ?? this.companions,
      photos: photos ?? this.photos,
      memo: memo ?? this.memo,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
    id,
    scheduleId,
    dateTime,
    stadium,
    homeTeam,
    awayTeam,
    myTeam,
    homeScore,
    awayScore,
    seatSection,
    seatNumber,
    temperature,
    rating,
    foodRating,
    atmosphereRating,
    ticketPrice,
    totalCost,
    highlights,
    createdAt,
    updatedAt,
    result,
    seatInfo,
    weather,
    companions,
    photos,
    memo,
    imageUrl,
    isFavorite,
  ];
}

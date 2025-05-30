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
  final Stadium stadium;
  final Team homeTeam;
  final Team awayTeam;
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

  /// 경기 날짜 (시간 제외)
  DateTime get gameDate =>
      DateTime(dateTime.year, dateTime.month, dateTime.day);

  @override
  List<Object?> get props => [
    id,
    dateTime,
    stadium,
    homeTeam,
    awayTeam,
    homeScore,
    awayScore,
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

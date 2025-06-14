class GameRecordForm {
  DateTime? gameDateTime;
  String? stadium;
  int? stadiumId;
  String? seatInfo;
  String? homeTeam;
  int? homeTeamId;
  String? awayTeam;
  int? awayTeamId;
  int? homeScore;
  int? awayScore;
  String? comment;
  bool isMemorableGame;
  bool isGameMinimum;
  String? imagePath;

  GameRecordForm({
    this.gameDateTime,
    this.stadium,
    this.stadiumId,
    this.seatInfo,
    this.homeTeam,
    this.homeTeamId,
    this.awayTeam,
    this.awayTeamId,
    this.homeScore,
    this.awayScore,
    this.comment,
    this.isMemorableGame = false,
    this.isGameMinimum = false,
    this.imagePath,
  });

  bool get isValid {
    return gameDateTime != null &&
           stadium != null &&
           stadiumId != null &&
           homeTeam != null &&
           homeTeamId != null &&
           awayTeam != null &&
           awayTeamId != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'gameDateTime': gameDateTime?.toIso8601String(),
      'stadium': stadium,
      'stadiumId': stadiumId,
      'seatInfo': seatInfo,
      'homeTeam': homeTeam,
      'homeTeamId': homeTeamId,
      'awayTeam': awayTeam,
      'awayTeamId': awayTeamId,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'comment': comment,
      'isMemorableGame': isMemorableGame,
      'isGameMinimum': isGameMinimum,
      'imagePath': imagePath,
    };
  }

  factory GameRecordForm.fromJson(Map<String, dynamic> json) {
    return GameRecordForm(
      gameDateTime: json['gameDateTime'] != null 
          ? DateTime.parse(json['gameDateTime']) 
          : null,
      stadium: json['stadium'],
      stadiumId: json['stadiumId'],
      seatInfo: json['seatInfo'],
      homeTeam: json['homeTeam'],
      homeTeamId: json['homeTeamId'],
      awayTeam: json['awayTeam'],
      awayTeamId: json['awayTeamId'],
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      comment: json['comment'],
      isMemorableGame: json['isMemorableGame'] ?? false,
      isGameMinimum: json['isGameMinimum'] ?? false,
      imagePath: json['imagePath'],
    );
  }
}

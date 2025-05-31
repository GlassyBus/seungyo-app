class GameRecordForm {
  DateTime? gameDateTime;
  String? stadium;
  String? seatInfo;
  String? homeTeam;
  String? awayTeam;
  int? homeScore;
  int? awayScore;
  String? comment;
  bool isMemorableGame;
  bool isGameMinimum;
  String? imagePath;

  GameRecordForm({
    this.gameDateTime,
    this.stadium,
    this.seatInfo,
    this.homeTeam,
    this.awayTeam,
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
           homeTeam != null &&
           awayTeam != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'gameDateTime': gameDateTime?.toIso8601String(),
      'stadium': stadium,
      'seatInfo': seatInfo,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
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
      seatInfo: json['seatInfo'],
      homeTeam: json['homeTeam'],
      awayTeam: json['awayTeam'],
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      comment: json['comment'],
      isMemorableGame: json['isMemorableGame'] ?? false,
      isGameMinimum: json['isGameMinimum'] ?? false,
      imagePath: json['imagePath'],
    );
  }
}

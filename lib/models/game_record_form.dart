class GameRecordForm {
  final DateTime? gameDateTime;
  final String? stadiumId;
  final String? homeTeamId;
  final String? awayTeamId;
  final int? homeScore;
  final int? awayScore;
  final String? seatInfo;
  final String? comment;
  final String? imagePath; // 하위 호환성을 위해 유지
  final List<String>? imagePaths; // 새로운 배열 필드
  final bool isFavorite;
  final bool canceled;

  GameRecordForm({
    this.gameDateTime,
    this.stadiumId,
    this.homeTeamId,
    this.awayTeamId,
    this.homeScore,
    this.awayScore,
    this.seatInfo,
    this.comment,
    this.imagePath,
    this.imagePaths,
    this.isFavorite = false,
    this.canceled = false,
  });

  bool get isValid {
    return gameDateTime != null && stadiumId != null && homeTeamId != null && awayTeamId != null;
  }

  GameRecordForm copyWith({
    DateTime? gameDateTime,
    String? stadiumId,
    String? homeTeamId,
    String? awayTeamId,
    int? homeScore,
    int? awayScore,
    String? seatInfo,
    String? comment,
    String? imagePath,
    List<String>? imagePaths,
    bool? isFavorite,
    bool? canceled,
  }) {
    return GameRecordForm(
      gameDateTime: gameDateTime ?? this.gameDateTime,
      stadiumId: stadiumId ?? this.stadiumId,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      seatInfo: seatInfo ?? this.seatInfo,
      comment: comment ?? this.comment,
      imagePath: imagePath ?? this.imagePath,
      imagePaths: imagePaths ?? this.imagePaths,
      isFavorite: isFavorite ?? this.isFavorite,
      canceled: canceled ?? this.canceled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameDateTime': gameDateTime?.toIso8601String(),
      'stadiumId': stadiumId,
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'seatInfo': seatInfo,
      'comment': comment,
      'imagePath': imagePath,
      'imagePaths': imagePaths,
      'isFavorite': isFavorite,
      'canceled': canceled,
    };
  }

  factory GameRecordForm.fromJson(Map<String, dynamic> json) {
    return GameRecordForm(
      gameDateTime: json['gameDateTime'] != null ? DateTime.parse(json['gameDateTime']) : null,
      stadiumId: json['stadiumId'],
      homeTeamId: json['homeTeamId'],
      awayTeamId: json['awayTeamId'],
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      seatInfo: json['seatInfo'],
      comment: json['comment'],
      imagePath: json['imagePath'],
      imagePaths: json['imagePaths']?.cast<String>(),
      isFavorite: json['isFavorite'] ?? false,
      canceled: json['canceled'] ?? false,
    );
  }
}

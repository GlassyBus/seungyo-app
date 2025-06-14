

class GameRecordData {
  final String homeTeamId;
  final String awayTeamId;
  final String stadiumId;
  final DateTime date;
  final int homeScore;
  final int awayScore;
  final String? seat;
  final String? comment;
  final bool isFavorite;
  final bool canceled;

  const GameRecordData({
    required this.homeTeamId,
    required this.awayTeamId,
    required this.stadiumId,
    required this.date,
    required this.homeScore,
    required this.awayScore,
    this.seat,
    this.comment,
    this.isFavorite = false,
    this.canceled = false,
  });

  factory GameRecordData.fromMap(Map<String, dynamic> map) {
    return GameRecordData(
      homeTeamId: map['homeTeamId'] ?? '',
      awayTeamId: map['awayTeamId'] ?? '',
      stadiumId: map['stadiumId'] ?? '',
      date: DateTime.parse(map['date']),
      homeScore: map['homeScore'] ?? 0,
      awayScore: map['awayScore'] ?? 0,
      seat: map['seat'],
      comment: map['comment'],
      isFavorite: map['isFavorite'] ?? false,
      canceled: map['canceled'] ?? false,
    );
  }
}

class RecordData {
  static final List<GameRecordData> records = _rawRecords.map((map) => GameRecordData.fromMap(map)).toList();

  static const List<Map<String, dynamic>> _rawRecords = [
    {
      "homeTeamId": "bears",
      "awayTeamId": "tigers",
      "stadiumId": "jamsil",
      "date": "2024-05-15T14:00:00",
      "homeScore": 5,
      "awayScore": 3,
      "seat": "1루 응원석 3층",
      "comment": "홈런이 3개나 나온 경기! 정말 재밌었다.",
      "isFavorite": true,
      "canceled": false,
    },
    {
      "homeTeamId": "twins",
      "awayTeamId": "bears",
      "stadiumId": "jamsil",
      "date": "2024-05-12T18:30:00",
      "homeScore": 2,
      "awayScore": 4,
      "seat": "3루 응원석 2층",
      "comment": "아쉬운 패배... 다음엔 꼭 이기자!",
      "isFavorite": false,
      "canceled": false,
    },
    {
      "homeTeamId": "bears",
      "awayTeamId": "lions",
      "stadiumId": "gocheok",
      "date": "2024-05-08T14:00:00",
      "homeScore": 3,
      "awayScore": 3,
      "seat": "1루 응원석 1층",
      "comment": "무승부로 끝났지만 좋은 경기였다.",
      "isFavorite": true,
      "canceled": false,
    },
  ];

  static GameRecordData? getById(int id) {
    return records.length > id ? records[id] : null;
  }

  static List<GameRecordData> getByTeam(String teamId) {
    return records.where((r) => r.homeTeamId == teamId || r.awayTeamId == teamId).toList();
  }
}

/// 경기 정보 모델
class Game {
  /// 경기 장소 및 시간
  final String location;

  /// 첫 번째 팀 이름
  final String team1;

  /// 첫 번째 팀 이미지 경로
  final String team1Image;

  /// 두 번째 팀 이름
  final String team2;

  /// 두 번째 팀 이미지 경로
  final String team2Image;

  /// 편집 아이콘 경로
  final String editIcon;

  /// 생성자
  const Game({
    required this.location,
    required this.team1,
    required this.team1Image,
    required this.team2,
    required this.team2Image,
    required this.editIcon,
  });

  /// 팩토리 메서드 - 기본값 설정된 인스턴스 생성
  factory Game.defaultGame({
    String? location,
    String? team1,
    String? team1Image,
    String? team2,
    String? team2Image,
  }) {
    return Game(
      location: location ?? '잠실, 18:30',
      team1: team1 ?? 'SSG',
      team1Image: team1Image ?? 'assets/emblems/ssg.png',
      team2: team2 ?? '두산',
      team2Image: team2Image ?? 'assets/emblems/doosan.png',
      editIcon: 'assets/icons/edit-20px.svg',
    );
  }
}

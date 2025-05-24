import 'package:seungyo/view/main/models/game.dart';

/// 게임 관련 Mock 데이터
class GameMocks {
  /// 오늘의 경기 목록
  static List<Game> todayGames = [
    Game(
      location: '고척, 14:00',
      team1: 'SSG',
      team1Image: 'assets/emblems/landers.png',
      team2: '키움',
      team2Image: 'assets/emblems/heroes.png',
      editIcon: 'assets/icons/edit-20px.svg',
    ),
    Game(
      location: '잠실, 17:00',
      team1: 'LG',
      team1Image: 'assets/emblems/twins.png',
      team2: 'KIA',
      team2Image: 'assets/emblems/tigers.png',
      editIcon: 'assets/icons/edit-20px.svg',
    ),
    Game(
      location: '잠실, 18:30',
      team1: '한화',
      team1Image: 'assets/emblems/eagles.png',
      team2: '삼성',
      team2Image: 'assets/emblems/lions.png',
      editIcon: 'assets/icons/edit-20px.svg',
    ),
  ];

  /// 내일 경기 목록
  static List<Game> tomorrowGames = [
    Game(
      location: '수원, 14:00',
      team1: 'KT',
      team1Image: 'assets/emblems/kt.png',
      team2: 'NC',
      team2Image: 'assets/emblems/nc.png',
      editIcon: 'assets/icons/edit-20px.svg',
    ),
    Game(
      location: '문학, 17:00',
      team1: 'SSG',
      team1Image: 'assets/emblems/ssg.png',
      team2: '롯데',
      team2Image: 'assets/emblems/lotte.png',
      editIcon: 'assets/icons/edit-20px.svg',
    ),
  ];

  /// 다음 주 경기 목록
  static List<Game> nextWeekGames = [
    Game(
      location: '창원, 17:00',
      team1: 'NC',
      team1Image: 'assets/emblems/nc.png',
      team2: 'KIA',
      team2Image: 'assets/emblems/kia.png',
      editIcon: 'assets/icons/edit-20px.svg',
    ),
    Game(
      location: '사직, 14:00',
      team1: '롯데',
      team1Image: 'assets/emblems/lotte.png',
      team2: 'SSG',
      team2Image: 'assets/emblems/ssg.png',
      editIcon: 'assets/icons/edit-20px.svg',
    ),
    Game(
      location: '대구, 18:30',
      team1: '삼성',
      team1Image: 'assets/emblems/samsung.png',
      team2: '두산',
      team2Image: 'assets/emblems/doosan.png',
      editIcon: 'assets/icons/edit-20px.svg',
    ),
  ];
}

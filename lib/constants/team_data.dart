import 'package:collection/collection.dart';

class Team {
  final String id;
  final String code;
  final String name;
  final String emblem;

  const Team({required this.id, required this.code, required this.name, required this.emblem});

  factory Team.fromMap(Map<String, String> map) {
    return Team(id: map['id'] ?? '', code: map['code'] ?? '', name: map['name'] ?? '', emblem: map['emblem'] ?? '');
  }
}

class TeamData {
  static final List<Team> teams = _rawTeams.map(Team.fromMap).toList();

  static const List<Map<String, String>> _rawTeams = [
    {"id": "tigers", "code": "KIA", "name": "KIA 타이거즈", "emblem": "assets/emblems/tigers.png"},
    {"id": "wiz", "code": "KT", "name": "KT 위즈", "emblem": "assets/emblems/wiz.png"},
    {"id": "twins", "code": "LG", "name": "LG 트윈스", "emblem": "assets/emblems/twins.png"},
    {"id": "dinos", "code": "NC", "name": "NC 다이노스", "emblem": "assets/emblems/dinos.png"},
    {"id": "landers", "code": "SSG", "name": "SSG 랜더스", "emblem": "assets/emblems/landers.png"},
    {"id": "bears", "code": "두산", "name": "두산 베어스", "emblem": "assets/emblems/bears.png"},
    {"id": "giants", "code": "롯데", "name": "롯데 자이언츠", "emblem": "assets/emblems/giants.png"},
    {"id": "lions", "code": "삼성", "name": "삼성 라이온즈", "emblem": "assets/emblems/lions.png"},
    {"id": "heroes", "code": "키움", "name": "키움 히어로즈", "emblem": "assets/emblems/heroes.png"},
    {"id": "eagles", "code": "한화", "name": "한화 이글스", "emblem": "assets/emblems/eagles.png"},
  ];

  static Team? getById(String id) {
    return teams.firstWhereOrNull((e) => e.id == id);
  }

  static Team? getByCode(String code) {
    return teams.firstWhereOrNull((e) => e.code == code);
  }
}

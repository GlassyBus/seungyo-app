class TeamData {
  static const List<Map<String, String>> teams = [
    {"code": "tigers", "name": "KIA 타이거즈", "emblem": "assets/emblems/tigers.png"},
    {"code": "wiz", "name": "KT 위즈", "emblem": "assets/emblems/wiz.png"},
    {"code": "twins", "name": "LG 트윈스", "emblem": "assets/emblems/twins.png"},
    {"code": "dinos", "name": "NC 다이노스", "emblem": "assets/emblems/dinos.png"},
    {"code": "landers", "name": "SSG 랜더스", "emblem": "assets/emblems/landers.png"},
    {"code": "bears", "name": "두산 베어스", "emblem": "assets/emblems/bears.png"},
    {"code": "giants", "name": "롯데 자이언츠", "emblem": "assets/emblems/giants.png"},
    {"code": "lions", "name": "삼성 라이온즈", "emblem": "assets/emblems/lions.png"},
    {"code": "heroes", "name": "키움 히어로즈", "emblem": "assets/emblems/heroes.png"},
    {"code": "eagles", "name": "한화 이글스", "emblem": "assets/emblems/eagles.png"},
  ];

  static Map<String, String>? getByName(String name) {
    return teams.firstWhere((e) => e['name'] == name, orElse: () => {});
  }
}

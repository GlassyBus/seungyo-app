import 'package:collection/collection.dart';

class Stadium {
  final String id;
  final String name;
  final String city;

  const Stadium({required this.id, required this.name, required this.city});

  factory Stadium.fromMap(Map<String, String> map) {
    return Stadium(id: map['id'] ?? '', name: map['name'] ?? '', city: map['city'] ?? '');
  }
}

class StadiumData {
  static final List<Stadium> stadiums = _rawStadiums.map(Stadium.fromMap).toList();

  static const List<Map<String, String>> _rawStadiums = [
    {"id": "incheon_ssg", "name": "인천SSG랜더스필드", "city": "인천"},
    {"id": "gocheok", "name": "고척스카이돔", "city": "서울"},
    {"id": "jamsil", "name": "잠실야구장", "city": "서울"},
    {"id": "gwangju_kia", "name": "광주-기아 챔피언스 필드", "city": "광주"},
    {"id": "suwon_kt", "name": "수원KT위즈파크", "city": "수원"},
    {"id": "daegu_samsung", "name": "대구삼성라이온즈파크", "city": "대구"},
    {"id": "sajik", "name": "사직야구장", "city": "부산"},
    {"id": "daejeon_hanwha", "name": "한화생명이글스파크", "city": "대전"},
    {"id": "changwon_nc", "name": "NC파크", "city": "창원"},
  ];

  static Stadium? getById(String id) {
    return stadiums.firstWhereOrNull((e) => e.id == id);
  }

  static Stadium? getByName(String name) {
    return stadiums.firstWhereOrNull((e) => e.name == name);
  }

  static List<Stadium> getByCity(String city) {
    return stadiums.where((e) => e.city == city).toList();
  }
}

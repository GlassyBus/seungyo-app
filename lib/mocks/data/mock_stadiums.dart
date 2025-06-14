import '../../models/stadium.dart';

/// Mock 구장 데이터
abstract class MockStadiums {
  static const List<Stadium> stadiums = [
    Stadium(
      id: 'incheon_ssg',
      name: '인천SSG랜더스필드',
      city: '인천',
      address: '인천광역시 미추홀구 매소홀로 618',
      capacity: 25000,
      latitude: 37.4369,
      longitude: 126.6933,
      homeTeam: 'SSG 랜더스',
      openedYear: 2021,
      description: 'SSG 랜더스의 홈구장',
    ),
    Stadium(
      id: 'gocheok',
      name: '고척스카이돔',
      city: '서울',
      address: '서울특별시 구로구 경인로 430',
      capacity: 25000,
      latitude: 37.4982,
      longitude: 126.8667,
      homeTeam: '키움 히어로즈',
      openedYear: 2015,
      description: '키움 히어로즈의 홈구장, 국내 최초 돔구장',
    ),
    Stadium(
      id: 'jamsil',
      name: '잠실야구장',
      city: '서울',
      address: '서울특별시 송파구 올림픽로 25',
      capacity: 25000,
      latitude: 37.5122,
      longitude: 127.0719,
      homeTeam: 'LG 트윈스, 두산 베어스',
      openedYear: 1982,
      description: 'LG 트윈스와 두산 베어스의 홈구장',
    ),
    Stadium(
      id: 'gwangju_kia',
      name: '광주-기아 챔피언스 필드',
      city: '광주',
      address: '광주광역시 북구 서림로 10',
      capacity: 20000,
      latitude: 35.1681,
      longitude: 126.8889,
      homeTeam: 'KIA 타이거즈',
      openedYear: 2014,
      description: 'KIA 타이거즈의 홈구장',
    ),
    Stadium(
      id: 'suwon_kt',
      name: '수원KT위즈파크',
      city: '수원',
      address: '경기도 수원시 영통구 원천동 산5번지',
      capacity: 20000,
      latitude: 37.2997,
      longitude: 127.0369,
      homeTeam: 'KT 위즈',
      openedYear: 2015,
      description: 'KT 위즈의 홈구장',
    ),
    Stadium(
      id: 'daegu_samsung',
      name: '대구삼성라이온즈파크',
      city: '대구',
      address: '대구광역시 수성구 야구전설로 1',
      capacity: 24000,
      latitude: 35.8411,
      longitude: 128.6811,
      homeTeam: '삼성 라이온즈',
      openedYear: 2016,
      description: '삼성 라이온즈의 홈구장',
    ),
    Stadium(
      id: 'sajik',
      name: '사직야구장',
      city: '부산',
      address: '부산광역시 동래구 사직로 45',
      capacity: 24500,
      latitude: 35.1939,
      longitude: 129.0614,
      homeTeam: '롯데 자이언츠',
      openedYear: 1985,
      description: '롯데 자이언츠의 홈구장',
    ),
    Stadium(
      id: 'daejeon_hanwha',
      name: '한화생명이글스파크',
      city: '대전',
      address: '대전광역시 중구 대종로 373',
      capacity: 13000,
      latitude: 36.3169,
      longitude: 127.4289,
      homeTeam: '한화 이글스',
      openedYear: 2019,
      description: '한화 이글스의 홈구장',
    ),
    Stadium(
      id: 'changwon_nc',
      name: 'NC파크',
      city: '창원',
      address: '경상남도 창원시 마산회원구 삼호로 63',
      capacity: 20000,
      latitude: 35.2225,
      longitude: 128.5825,
      homeTeam: 'NC 다이노스',
      openedYear: 2019,
      description: 'NC 다이노스의 홈구장',
    ),
  ];

  /// 구장 ID로 구장 찾기
  static Stadium? findById(String id) {
    try {
      return stadiums.firstWhere((stadium) => stadium.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 구장 이름으로 구장 찾기
  static Stadium? findByName(String name) {
    try {
      return stadiums.firstWhere((stadium) => stadium.name == name);
    } catch (e) {
      return null;
    }
  }

  /// 도시별 구장 목록
  static List<Stadium> getStadiumsByCity(String city) {
    return stadiums.where((stadium) => stadium.city == city).toList();
  }

  /// 홈팀별 구장 찾기
  static Stadium? findByHomeTeam(String teamName) {
    try {
      return stadiums.firstWhere(
        (stadium) => stadium.homeTeam?.contains(teamName) == true,
      );
    } catch (e) {
      return null;
    }
  }
}

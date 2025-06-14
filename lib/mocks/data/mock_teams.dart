import 'package:flutter/material.dart';

import '../../models/team.dart';

/// Mock 팀 데이터
abstract class MockTeams {
  static const List<Team> teams = [
    Team(
      id: 'ssg',
      name: 'SSG 랜더스',
      shortName: 'SSG',
      englishName: 'SSG Landers',
      logo: '⚡',
      primaryColor: Color(0xFF003366),
      secondaryColor: Color(0xFFFFD700),
      city: '인천',
      stadium: '인천SSG랜더스필드',
      foundedYear: 2021,
      description: '인천을 연고지로 하는 프로야구팀',
    ),
    Team(
      id: 'kiwoom',
      name: '키움 히어로즈',
      shortName: '키움',
      englishName: 'Kiwoom Heroes',
      logo: '🦸‍♂️',
      primaryColor: Color(0xFF8B0000),
      secondaryColor: Color(0xFFFFD700),
      city: '서울',
      stadium: '고척스카이돔',
      foundedYear: 2008,
      description: '서울을 연고지로 하는 프로야구팀',
    ),
    Team(
      id: 'lg',
      name: 'LG 트윈스',
      shortName: 'LG',
      englishName: 'LG Twins',
      logo: '⚾',
      primaryColor: Color(0xFFFF0000),
      secondaryColor: Color(0xFF000000),
      city: '서울',
      stadium: '잠실야구장',
      foundedYear: 1982,
      description: '서울을 연고지로 하는 프로야구팀',
    ),
    Team(
      id: 'kia',
      name: 'KIA 타이거즈',
      shortName: 'KIA',
      englishName: 'KIA Tigers',
      logo: '🐅',
      primaryColor: Color(0xFF000000),
      secondaryColor: Color(0xFFFF0000),
      city: '광주',
      stadium: '광주-기아 챔피언스 필드',
      foundedYear: 1982,
      description: '광주를 연고지로 하는 프로야구팀',
    ),
    Team(
      id: 'doosan',
      name: '두산 베어스',
      shortName: '두산',
      englishName: 'Doosan Bears',
      logo: '🐻',
      primaryColor: Color(0xFF000080),
      secondaryColor: Color(0xFFFFFFFF),
      city: '서울',
      stadium: '잠실야구장',
      foundedYear: 1982,
      description: '서울을 연고지로 하는 프로야구팀',
    ),
    Team(
      id: 'kt',
      name: 'KT 위즈',
      shortName: 'KT',
      englishName: 'KT Wiz',
      logo: '🧙‍♂️',
      primaryColor: Color(0xFF000000),
      secondaryColor: Color(0xFFFF0000),
      city: '수원',
      stadium: '수원KT위즈파크',
      foundedYear: 2013,
      description: '수원을 연고지로 하는 프로야구팀',
    ),
    Team(
      id: 'samsung',
      name: '삼성 라이온즈',
      shortName: '삼성',
      englishName: 'Samsung Lions',
      logo: '🦁',
      primaryColor: Color(0xFF0066CC),
      secondaryColor: Color(0xFFFFFFFF),
      city: '대구',
      stadium: '대구삼성라이온즈파크',
      foundedYear: 1982,
      description: '대구를 연고지로 하는 프로야구팀',
    ),
    Team(
      id: 'lotte',
      name: '롯데 자이언츠',
      shortName: '롯데',
      englishName: 'Lotte Giants',
      logo: '⚾',
      primaryColor: Color(0xFF003366),
      secondaryColor: Color(0xFFFF0000),
      city: '부산',
      stadium: '사직야구장',
      foundedYear: 1982,
      description: '부산을 연고지로 하는 프로야구팀',
    ),
    Team(
      id: 'hanwha',
      name: '한화 이글스',
      shortName: '한화',
      englishName: 'Hanwha Eagles',
      logo: '🦅',
      primaryColor: Color(0xFFFF6600),
      secondaryColor: Color(0xFF000000),
      city: '대전',
      stadium: '한화생명이글스파크',
      foundedYear: 1985,
      description: '대전을 연고지로 하는 프로야구팀',
    ),
    Team(
      id: 'nc',
      name: 'NC 다이노스',
      shortName: 'NC',
      englishName: 'NC Dinos',
      logo: '🦕',
      primaryColor: Color(0xFF003366),
      secondaryColor: Color(0xFFFFD700),
      city: '창원',
      stadium: 'NC파크',
      foundedYear: 2011,
      description: '창원을 연고지로 하는 프로야구팀',
    ),
  ];

  /// 팀 ID로 팀 찾기
  static Team? findById(String id) {
    try {
      return teams.firstWhere((team) => team.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 팀 이름으로 팀 찾기
  static Team? findByName(String name) {
    try {
      return teams.firstWhere(
        (team) => team.name == name || team.shortName == name,
      );
    } catch (e) {
      return null;
    }
  }

  /// 도시별 팀 목록
  static List<Team> getTeamsByCity(String city) {
    return teams.where((team) => team.city == city).toList();
  }
}

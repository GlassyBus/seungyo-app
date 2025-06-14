import '../../models/game_record.dart';
import '../../models/stadium.dart';
import '../../models/team.dart';
import 'package:flutter/material.dart';

/// Mock 게임 기록 데이터 (Figma 디자인 기반)
abstract class MockGameRecords {
  static final List<GameRecord> records = [
    GameRecord(
      id: 1,
      dateTime: DateTime(2025, 4, 6, 14, 0),
      stadium: const Stadium(id: 'gocheok', name: '고척스카이돔', city: '서울'),
      homeTeam: const Team(
        id: 'ssg',
        name: 'SSG 랜더스',
        shortName: 'SSG',
        primaryColor: Color(0xFFCE0E2D),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      awayTeam: const Team(
        id: 'kiwoom',
        name: '키움 히어로즈',
        shortName: '키움',
        primaryColor: Color(0xFF820024),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      homeScore: 1,
      awayScore: 0,
      myTeam: const Team(
        id: 'ssg',
        name: 'SSG 랜더스',
        shortName: 'SSG',
        primaryColor: Color(0xFFCE0E2D),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      result: GameResult.win,
      imageUrl:
          'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/_EC_8A_B9_EC_9A_94__EC_8A_B9_EB_A6_AC_EC_9A_94_EC_A0_95_-By8lFfD1ARdfwMbzmHuZMZIX45CcpZ.png',
      isFavorite: true,
    ),
    GameRecord(
      id: 2,
      dateTime: DateTime(2025, 4, 6, 14, 0),
      stadium: const Stadium(id: 'jamsil', name: '잠실실내체육관', city: '서울'),
      homeTeam: const Team(
        id: 'lg',
        name: 'LG 트윈스',
        shortName: 'LG',
        primaryColor: Color(0xFFC30452),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      awayTeam: const Team(
        id: 'kia',
        name: 'KIA 타이거즈',
        shortName: 'KIA',
        primaryColor: Color(0xFFEA0029),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      homeScore: 1,
      awayScore: 0,
      myTeam: const Team(
        id: 'lg',
        name: 'LG 트윈스',
        shortName: 'LG',
        primaryColor: Color(0xFFC30452),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      result: GameResult.win,
      imageUrl:
          'https://hebbkx1anhila5yf.public.blob.vercel-storage.com/_EC_8A_B9_EC_9A_94__EC_8A_B9_EB_A6_AC_EC_9A_94_EC_A0_95_-SWi6klnULqXDwaFGW0DRfgElFSd4sB.png',
      isFavorite: false,
    ),
    GameRecord(
      id: 3,
      dateTime: DateTime(2025, 4, 6, 14, 0),
      stadium: const Stadium(id: 'gocheok', name: '고척스카이돔', city: '서울'),
      homeTeam: const Team(
        id: 'ssg',
        name: 'SSG 랜더스',
        shortName: 'SSG',
        primaryColor: Color(0xFFCE0E2D),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      awayTeam: const Team(
        id: 'kiwoom',
        name: '키움 히어로즈',
        shortName: '키움',
        primaryColor: Color(0xFF820024),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      homeScore: 0,
      awayScore: 1,
      myTeam: const Team(
        id: 'ssg',
        name: 'SSG 랜더스',
        shortName: 'SSG',
        primaryColor: Color(0xFFCE0E2D),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      result: GameResult.lose,
      imageUrl:
          'https://images.unsplash.com/photo-1544398640-94b86f875d28?q=80&w=312&h=312&fit=crop',
      isFavorite: true,
    ),
    GameRecord(
      id: 4,
      dateTime: DateTime(2025, 4, 6, 14, 0),
      stadium: const Stadium(id: 'gocheok', name: '고척스카이돔', city: '서울'),
      homeTeam: const Team(
        id: 'nc',
        name: 'NC 다이노스',
        shortName: 'NC',
        primaryColor: Color(0xFF315C8D),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      awayTeam: const Team(
        id: 'kiwoom',
        name: '키움 히어로즈',
        shortName: '키움',
        primaryColor: Color(0xFF820024),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      homeScore: 1,
      awayScore: 0,
      myTeam: const Team(
        id: 'nc',
        name: 'NC 다이노스',
        shortName: 'NC',
        primaryColor: Color(0xFF315C8D),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      result: GameResult.win,
      imageUrl: null, // No image to test placeholder
      isFavorite: true,
    ),
    GameRecord(
      id: 5,
      dateTime: DateTime(2025, 4, 6, 14, 0),
      stadium: const Stadium(id: 'jamsil', name: '잠실실내체육관', city: '서울'),
      homeTeam: const Team(
        id: 'doosan',
        name: '두산 베어스',
        shortName: '두산',
        primaryColor: Color(0xFF131230),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      awayTeam: const Team(
        id: 'lotte',
        name: '롯데 자이언츠',
        shortName: '롯데',
        primaryColor: Color(0xFF002856),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      homeScore: 1,
      awayScore: 1,
      myTeam: const Team(
        id: 'doosan',
        name: '두산 베어스',
        shortName: '두산',
        primaryColor: Color(0xFF131230),
        secondaryColor: Color(0xFFFFFFFF),
      ),
      result: GameResult.draw,
      imageUrl:
          'https://images.unsplash.com/photo-1628926933973-3a21c881516b?q=80&w=312&h=312&fit=crop',
      isFavorite: true,
    ),
  ];
}

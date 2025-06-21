import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:seungyo/constants/stadium_data.dart' as stadium_data;
import 'package:seungyo/constants/team_data.dart' as team_data;
import 'package:seungyo/database/database.dart';
import 'package:seungyo/models/game_record.dart';
import 'package:seungyo/models/stadium.dart' as app_models;
import 'package:seungyo/models/team.dart' as app_models;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  late AppDatabase _database;

  AppDatabase get database => _database;

  Future<void> initialize() async {
    _database = AppDatabase();
    await _initializeDefaultData();
  }

  Future<void> _initializeDefaultData() async {
    try {
      if (kDebugMode) {
        print('Starting database initialization...');
      }

      // 팀 데이터가 비어있으면 기본 데이터 삽입
      final existingTeams = await _database.getAllTeams();
      if (kDebugMode) {
        print('Existing teams count: ${existingTeams.length}');
      }
      if (existingTeams.isEmpty) {
        if (kDebugMode) {
          print('Inserting team data...');
        }
        await _insertTeamData();
        if (kDebugMode) {
          print('Team data inserted successfully');
        }
      }

      // 경기장 데이터가 비어있으면 기본 데이터 삽입
      final existingStadiums = await _database.getAllStadiums();
      if (kDebugMode) {
        print('Existing stadiums count: ${existingStadiums.length}');
      }
      if (existingStadiums.isEmpty) {
        if (kDebugMode) {
          print('Inserting stadium data...');
        }
        await _insertStadiumData();
        if (kDebugMode) {
          print('Stadium data inserted successfully');
        }
      }

      // 기록 데이터는 목업을 넣지 않고 사용자가 직접 추가하도록 함
      final existingRecords = await _database.getAllRecords();
      if (kDebugMode) {
        print('Existing records count: ${existingRecords.length}');
      }
      // if (existingRecords.isEmpty) {
      //   if (kDebugMode) if (kDebugMode) print('Inserting record data...');
      //   await _insertRecordData();
      //   if (kDebugMode) if (kDebugMode) print('Record data inserted successfully');
      // }

      if (kDebugMode) {
        print('Database initialization completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing default data: $e');
        print('Error stack trace: ${StackTrace.current}');
      }
    }
  }

  Future<void> _insertTeamData() async {
    try {
      final teams = team_data.TeamData.teams;
      if (kDebugMode) {
        print('Found ${teams.length} teams to insert');
      }
      for (int i = 0; i < teams.length; i++) {
        final team = teams[i];
        if (kDebugMode) {
          print('Inserting team: ${team.name} (${team.id})');
        }
        await _database.insertTeam(
          TeamsCompanion.insert(
            id: team.id,
            name: team.name,
            code: team.code,
            emblem: Value(team.emblem),
          ),
        );
      }
      if (kDebugMode) {
        print('All teams inserted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting team data: $e');
        print('Error stack trace: ${StackTrace.current}');
      }
    }
  }

  Future<void> _insertStadiumData() async {
    try {
      final stadiums = stadium_data.StadiumData.stadiums;
      if (kDebugMode) {
        print('Found ${stadiums.length} stadiums to insert');
      }
      for (final stadium in stadiums) {
        if (kDebugMode) {
          print('Inserting stadium: ${stadium.name} (${stadium.id})');
        }
        await _database.insertStadium(
          StadiumsCompanion.insert(
            id: stadium.id,
            name: stadium.name,
            city: Value(stadium.city),
          ),
        );
      }
      if (kDebugMode) {
        print('All stadiums inserted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting stadium data: $e');
        print('Error stack trace: ${StackTrace.current}');
      }
    }
  }

  // Future<void> _insertRecordData() async {
  //   try {
  //     final records = record_data.RecordData.records;

  //     for (final record in records) {
  //       await _database.insertRecord(
  //         RecordsCompanion.insert(
  //           date: record.date,
  //           stadiumId: record.stadiumId,
  //           homeTeamId: record.homeTeamId,
  //           awayTeamId: record.awayTeamId,
  //           homeScore: record.homeScore,
  //           awayScore: record.awayScore,
  //           seat: Value(record.seat),
  //           comment: Value(record.comment),
  //           isFavorite: Value(record.isFavorite),
  //           canceled: Value(record.canceled),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (kDebugMode) if (kDebugMode) print('Error inserting record data: $e');
  //   }
  // }

  // Database 모델을 앱 모델로 변환하는 유틸리티 메서드들

  /// Database Team을 App Team 모델로 변환
  Future<List<app_models.Team>> getTeamsAsAppModels() async {
    try {
      final dbTeams = await _database.getAllTeams();
      return dbTeams
          .map(
            (dbTeam) => app_models.Team(
              id: dbTeam.id.toString(),
              name: dbTeam.name,
              shortName: dbTeam.code,
              primaryColor: _getTeamPrimaryColor(dbTeam.id),
              // 팀별 고유 색상
              secondaryColor: Colors.white,
              logo: dbTeam.emblem,
              logoUrl: dbTeam.emblem, // emblem을 logoUrl로도 사용
            ),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error converting teams to app models: $e');
      }
      return [];
    }
  }

  /// 팀별 고유 색상 반환 (실제 팀 색상으로 매핑)
  Color _getTeamPrimaryColor(String teamId) {
    switch (teamId) {
      case 'twins':
      case 'LG':
        return const Color(0xFFC30452); // LG 트윈스 레드
      case 'wiz':
      case 'KT':
        return const Color(0xFF000000); // KT 위즈 블랙
      case 'landers':
      case 'SSG':
        return const Color(0xFFCE0E2D); // SSG 랜더스 레드
      case 'dinos':
      case 'NC':
        return const Color(0xFF315288); // NC 다이노스 네이비
      case 'bears':
      case '두산':
        return const Color(0xFF131A2B); // 두산 베어스 네이비
      case 'tigers':
      case 'KIA':
        return const Color(0xFFEA0029); // KIA 타이거즈 레드
      case 'giants':
      case '롯데':
        return const Color(0xFF041E42); // 롯데 자이언츠 네이비
      case 'lions':
      case '삼성':
        return const Color(0xFF1E3A8A); // 삼성 라이온즈 블루
      case 'eagles':
      case '한화':
        return const Color(0xFFFF6900); // 한화 이글스 오렌지
      case 'heroes':
      case '키움':
        return const Color(0xFF570514); // 키움 히어로즈 버건디
      default:
        return Colors.blue; // 기본 색상
    }
  }

  /// 팀별 보조 색상 반환
  Color _getTeamSecondaryColor(String teamId) {
    switch (teamId) {
      case 'twins':
      case 'LG':
        return Colors.white;
      case 'wiz':
      case 'KT':
        return const Color(0xFFED1C24); // KT 레드
      case 'landers':
      case 'SSG':
        return const Color(0xFFFFD100); // SSG 골드
      case 'dinos':
      case 'NC':
        return const Color(0xFFFFD100); // NC 골드
      case 'bears':
      case '두산':
        return Colors.white;
      case 'tigers':
      case 'KIA':
        return Colors.white;
      case 'giants':
      case '롯데':
        return Colors.white;
      case 'lions':
      case '삼성':
        return Colors.white;
      case 'eagles':
      case '한화':
        return Colors.white;
      case 'heroes':
      case '키움':
        return const Color(0xFFFFD100); // 키움 골드
      default:
        return Colors.white;
    }
  }

  /// Database Stadium을 App Stadium 모델로 변환
  Future<List<app_models.Stadium>> getStadiumsAsAppModels() async {
    try {
      final dbStadiums = await _database.getAllStadiums();
      return dbStadiums
          .map(
            (dbStadium) => app_models.Stadium(
              id: dbStadium.id.toString(),
              name: dbStadium.name,
              city: dbStadium.city ?? '',
            ),
          )
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error converting stadiums to app models: $e');
      }
      return [];
    }
  }

  /// Database Record를 App GameRecord 모델로 변환
  Future<GameRecord?> convertRecordToGameRecord(Record dbRecord) async {
    try {
      // 팀과 경기장 정보 가져오기
      final homeTeam = await _database.getTeamById(dbRecord.homeTeamId);
      final awayTeam = await _database.getTeamById(dbRecord.awayTeamId);
      final stadium = await _database.getStadiumById(dbRecord.stadiumId);

      if (homeTeam == null || awayTeam == null || stadium == null) {
        return null;
      }

      // GameResult 계산
      GameResult result;
      if (dbRecord.canceled) {
        // 취소된 경기는 cancel 결과로 설정
        result = GameResult.cancel;
      } else if (dbRecord.homeScore > dbRecord.awayScore) {
        result = GameResult.win;
      } else if (dbRecord.homeScore < dbRecord.awayScore) {
        result = GameResult.lose;
      } else {
        result = GameResult.draw;
      }

      // photos 파싱
      List<String> photos = [];
      if (dbRecord.photosJson != null && dbRecord.photosJson!.isNotEmpty) {
        try {
          photos = List<String>.from(json.decode(dbRecord.photosJson!));
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing photos JSON: $e');
          }
        }
      }

      return GameRecord(
        id: dbRecord.id,
        dateTime: dbRecord.date,
        stadium: app_models.Stadium(
          id: stadium.id,
          name: stadium.name,
          city: stadium.city ?? '',
        ),
        homeTeam: app_models.Team(
          id: homeTeam.id,
          name: homeTeam.name,
          shortName: homeTeam.code,
          primaryColor: _getTeamPrimaryColor(homeTeam.id),
          secondaryColor: _getTeamSecondaryColor(homeTeam.id),
          logo: homeTeam.emblem,
          logoUrl: homeTeam.emblem,
        ),
        awayTeam: app_models.Team(
          id: awayTeam.id,
          name: awayTeam.name,
          shortName: awayTeam.code,
          primaryColor: _getTeamPrimaryColor(awayTeam.id),
          secondaryColor: _getTeamSecondaryColor(awayTeam.id),
          logo: awayTeam.emblem,
          logoUrl: awayTeam.emblem,
        ),
        homeScore: dbRecord.homeScore,
        awayScore: dbRecord.awayScore,
        result: result,
        seatInfo: dbRecord.seat,
        memo: dbRecord.comment ?? '',
        photos: photos,
        isFavorite: dbRecord.isFavorite,
        canceled: dbRecord.canceled,
        createdAt: dbRecord.createdAt,

        // DB에 없는 필드들은 기본값으로 설정
        weather: '',
        companions: [],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error converting record to game record: $e');
      }
      return null;
    }
  }

  /// 모든 게임 기록을 앱 모델로 변환하여 가져오기
  Future<List<GameRecord>> getAllGameRecords() async {
    try {
      final dbRecords = await _database.getAllRecords();
      final gameRecords = <GameRecord>[];

      for (final dbRecord in dbRecords) {
        final gameRecord = await convertRecordToGameRecord(dbRecord);
        if (gameRecord != null) {
          gameRecords.add(gameRecord);
        }
      }

      return gameRecords;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all game records: $e');
      }
      return [];
    }
  }

  // 디버그용 메서드들
  Future<void> printDatabaseStatus() async {
    try {
      if (kDebugMode) {
        print('=== DATABASE STATUS ===');
      }

      // 팀 데이터 확인
      final teams = await _database.getAllTeams();
      if (kDebugMode) {
        print('Teams count: ${teams.length}');
      }
      if (teams.isNotEmpty) {
        if (kDebugMode) {
          print('First 3 teams:');
        }
        for (int i = 0; i < (teams.length > 3 ? 3 : teams.length); i++) {
          final team = teams[i];
          if (kDebugMode) {
            print('  - ${team.id}: ${team.name} (${team.code})');
          }
        }
      }

      // 경기장 데이터 확인
      final stadiums = await _database.getAllStadiums();
      if (kDebugMode) {
        print('Stadiums count: ${stadiums.length}');
      }
      if (stadiums.isNotEmpty) {
        if (kDebugMode) {
          print('First 3 stadiums:');
        }
        for (int i = 0; i < (stadiums.length > 3 ? 3 : stadiums.length); i++) {
          final stadium = stadiums[i];
          if (kDebugMode) {
            print('  - ${stadium.id}: ${stadium.name} (${stadium.city})');
          }
        }
      }

      // 기록 데이터 확인
      final records = await _database.getAllRecords();
      if (kDebugMode) {
        print('Records count: ${records.length}');
      }
      if (records.isNotEmpty) {
        if (kDebugMode) {
          print('First 3 records:');
        }
        for (int i = 0; i < (records.length > 3 ? 3 : records.length); i++) {
          final record = records[i];
          if (kDebugMode) {
            print(
              '  - Record ${record.id}: ${record.date} at ${record.stadiumId}',
            );
            print(
              '    ${record.homeTeamId} vs ${record.awayTeamId} (${record.homeScore}-${record.awayScore})',
            );
          }
        }
      }

      if (kDebugMode) {
        print('======================');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking database status: $e');
      }
    }
  }

  Future<void> printAllTeams() async {
    try {
      final teams = await _database.getAllTeams();
      if (kDebugMode) {
        print('=== ALL TEAMS (${teams.length}) ===');
      }
      for (final team in teams) {
        if (kDebugMode) {
          print(
            'ID: ${team.id}, Name: ${team.name}, Code: ${team.code}, Emblem: ${team.emblem}',
          );
        }
      }
      if (kDebugMode) {
        print('========================');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error printing teams: $e');
      }
    }
  }

  Future<void> printAllStadiums() async {
    try {
      final stadiums = await _database.getAllStadiums();
      if (kDebugMode) {
        print('=== ALL STADIUMS (${stadiums.length}) ===');
      }
      for (final stadium in stadiums) {
        if (kDebugMode) {
          print(
            'ID: ${stadium.id}, Name: ${stadium.name}, City: ${stadium.city}',
          );
        }
      }
      if (kDebugMode) {
        print('============================');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error printing stadiums: $e');
      }
    }
  }

  Future<void> printAllRecords() async {
    try {
      final records = await _database.getAllRecords();
      if (kDebugMode) {
        print('=== ALL RECORDS (${records.length}) ===');
      }
      for (final record in records) {
        if (kDebugMode) {
          print('ID: ${record.id}');
          print('Date: ${record.date}');
          print('Stadium: ${record.stadiumId}');
          print('Teams: ${record.homeTeamId} vs ${record.awayTeamId}');
          print('Score: ${record.homeScore}-${record.awayScore}');
          print('Seat: ${record.seat}');
          print('Comment: ${record.comment}');
          print('Favorite: ${record.isFavorite}');
          print('Canceled: ${record.canceled}');
          print('Created: ${record.createdAt}');
          print('---');
        }
      }
      if (kDebugMode) {
        print('=========================');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error printing records: $e');
      }
    }
  }

  Future<void> dispose() async {
    try {
      await _database.close();
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing database: $e');
      }
    }
  }
}

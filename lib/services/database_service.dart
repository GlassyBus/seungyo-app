import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:seungyo/constants/record_data.dart' as record_data;
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
      // 팀 데이터가 비어있으면 기본 데이터 삽입
      final existingTeams = await _database.getAllTeams();
      if (existingTeams.isEmpty) {
        await _insertTeamData();
      }

      // 경기장 데이터가 비어있으면 기본 데이터 삽입
      final existingStadiums = await _database.getAllStadiums();
      if (existingStadiums.isEmpty) {
        await _insertStadiumData();
      }

      // 기록 데이터가 비어있으면 기본 데이터 삽입
      final existingRecords = await _database.getAllRecords();
      if (existingRecords.isEmpty) {
        await _insertRecordData();
      }
    } catch (e) {
      print('Error initializing default data: $e');
    }
  }

  Future<void> _insertTeamData() async {
    try {
      final teams = team_data.TeamData.teams;
      for (int i = 0; i < teams.length; i++) {
        final team = teams[i];
        await _database.insertTeam(
          TeamsCompanion.insert(id: team.id, name: team.name, code: team.code, emblem: Value(team.emblem)),
        );
      }
    } catch (e) {
      print('Error inserting team data: $e');
    }
  }

  Future<void> _insertStadiumData() async {
    try {
      final stadiums = stadium_data.StadiumData.stadiums;

      for (final stadium in stadiums) {
        await _database.insertStadium(
          StadiumsCompanion.insert(id: stadium.id, name: stadium.name, city: Value(stadium.city)),
        );
      }
    } catch (e) {
      print('Error inserting stadium data: $e');
    }
  }

  Future<void> _insertRecordData() async {
    try {
      final records = record_data.RecordData.records;

      for (final record in records) {
        await _database.insertRecord(
          RecordsCompanion.insert(
            date: record.date,
            stadiumId: record.stadiumId,
            homeTeamId: record.homeTeamId,
            awayTeamId: record.awayTeamId,
            homeScore: record.homeScore,
            awayScore: record.awayScore,
            seat: Value(record.seat),
            comment: Value(record.comment),
            isFavorite: Value(record.isFavorite),
            canceled: Value(record.canceled),
          ),
        );
      }
    } catch (e) {
      print('Error inserting record data: $e');
    }
  }

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
              primaryColor: Colors.blue,
              // 기본값 - 실제로는 데이터베이스에서 가져와야 함
              secondaryColor: Colors.white,
              logo: dbTeam.emblem,
            ),
          )
          .toList();
    } catch (e) {
      print('Error converting teams to app models: $e');
      return [];
    }
  }

  /// Database Stadium을 App Stadium 모델로 변환
  Future<List<app_models.Stadium>> getStadiumsAsAppModels() async {
    try {
      final dbStadiums = await _database.getAllStadiums();
      return dbStadiums
          .map(
            (dbStadium) =>
                app_models.Stadium(id: dbStadium.id.toString(), name: dbStadium.name, city: dbStadium.city ?? ''),
          )
          .toList();
    } catch (e) {
      print('Error converting stadiums to app models: $e');
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
      if (dbRecord.homeScore > dbRecord.awayScore) {
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
          print('Error parsing photos JSON: $e');
        }
      }

      return GameRecord(
        id: dbRecord.id,
        dateTime: dbRecord.date,
        stadium: app_models.Stadium(id: stadium.id, name: stadium.name, city: stadium.city ?? ''),
        homeTeam: app_models.Team(
          id: homeTeam.id,
          name: homeTeam.name,
          shortName: homeTeam.code,
          primaryColor: Colors.blue,
          secondaryColor: Colors.white,
          logo: homeTeam.emblem,
        ),
        awayTeam: app_models.Team(
          id: awayTeam.id,
          name: awayTeam.name,
          shortName: awayTeam.code,
          primaryColor: Colors.red,
          secondaryColor: Colors.white,
          logo: awayTeam.emblem,
        ),
        homeScore: dbRecord.homeScore,
        awayScore: dbRecord.awayScore,
        result: result,
        seatInfo: dbRecord.seat,
        memo: dbRecord.comment ?? '',
        photos: photos,
        isFavorite: dbRecord.isFavorite,
        createdAt: dbRecord.createdAt,

        // DB에 없는 필드들은 기본값으로 설정
        weather: '',
        companions: [],
      );
    } catch (e) {
      print('Error converting record to game record: $e');
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
      print('Error getting all game records: $e');
      return [];
    }
  }

  Future<void> dispose() async {
    try {
      await _database.close();
    } catch (e) {
      print('Error disposing database: $e');
    }
  }
}

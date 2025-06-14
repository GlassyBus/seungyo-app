import 'package:seungyo/database/database.dart';
import 'package:seungyo/constants/team_data.dart' as team_data;
import 'package:seungyo/models/team.dart' as app_models;
import 'package:seungyo/models/stadium.dart' as app_models;
import 'package:seungyo/models/game_record.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

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
          TeamsCompanion.insert(
            name: team.name,
            code: team.code,
            emblem: Value(team.emblem),
          ),
        );
      }
    } catch (e) {
      print('Error inserting team data: $e');
    }
  }

  Future<void> _insertStadiumData() async {
    try {
      final stadiums = [
        {'name': '광주-기아 챔피언스 필드', 'city': '광주'},
        {'name': '월명종합경기장 야구장', 'city': '청주'},
        {'name': '대구 삼성 라이온즈 파크', 'city': '대구'},
        {'name': '포항 야구장', 'city': '포항'},
        {'name': '서울종합운동장 야구장', 'city': '서울'},
        {'name': '잠실야구장', 'city': '서울'},
        {'name': '수원 케이티 위즈 파크', 'city': '수원'},
        {'name': '인천 SSG 랜더스필드', 'city': '인천'},
        {'name': '사직 야구장', 'city': '부산'},
        {'name': '울산 문수 야구장', 'city': '울산'},
        {'name': '대전 한화생명 볼파크', 'city': '대전'},
        {'name': '청주 야구장', 'city': '청주'},
        {'name': '창원 NC 파크', 'city': '창원'},
        {'name': '고척 스카이돔', 'city': '서울'},
      ];

      for (final stadium in stadiums) {
        await _database.insertStadium(
          StadiumsCompanion.insert(
            name: stadium['name']!,
            city: Value(stadium['city']),
          ),
        );
      }
    } catch (e) {
      print('Error inserting stadium data: $e');
    }
  }

  // Database 모델을 앱 모델로 변환하는 유틸리티 메서드들
  
  /// Database Team을 App Team 모델로 변환
  Future<List<app_models.Team>> getTeamsAsAppModels() async {
    try {
      final dbTeams = await _database.getAllTeams();
      return dbTeams.map((dbTeam) => app_models.Team(
        id: dbTeam.id.toString(),
        name: dbTeam.name,
        shortName: dbTeam.code,
        primaryColor: Colors.blue, // 기본값 - 실제로는 데이터베이스에서 가져와야 함
        secondaryColor: Colors.white,
        logo: dbTeam.emblem,
      )).toList();
    } catch (e) {
      print('Error converting teams to app models: $e');
      return [];
    }
  }

  /// Database Stadium을 App Stadium 모델로 변환
  Future<List<app_models.Stadium>> getStadiumsAsAppModels() async {
    try {
      final dbStadiums = await _database.getAllStadiums();
      return dbStadiums.map((dbStadium) => app_models.Stadium(
        id: dbStadium.id.toString(),
        name: dbStadium.name,
        city: dbStadium.city ?? '',
      )).toList();
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

      return GameRecord(
        id: dbRecord.id,
        dateTime: dbRecord.date,
        stadium: app_models.Stadium(
          id: stadium.id.toString(),
          name: stadium.name,
          city: stadium.city ?? '',
        ),
        homeTeam: app_models.Team(
          id: homeTeam.id.toString(),
          name: homeTeam.name,
          shortName: homeTeam.code,
          primaryColor: Colors.blue,
          secondaryColor: Colors.white,
          logo: homeTeam.emblem,
        ),
        awayTeam: app_models.Team(
          id: awayTeam.id.toString(),
          name: awayTeam.name,
          shortName: awayTeam.code,
          primaryColor: Colors.red,
          secondaryColor: Colors.white,
          logo: awayTeam.emblem,
        ),
        homeScore: dbRecord.homeScore,
        awayScore: dbRecord.awayScore,
        result: result,
        memo: dbRecord.comment ?? '',
        seatInfo: dbRecord.seat,
        isFavorite: dbRecord.isFavorite,
        photos: dbRecord.photosJson != null 
            ? List<String>.from(json.decode(dbRecord.photosJson!))
            : [],
      );
    } catch (e) {
      print('Error converting record to game record: $e');
      return null;
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

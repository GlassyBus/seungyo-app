import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import '../database/database.dart';
import '../models/game_record.dart';
import '../models/game_record_form.dart';
import '../services/database_service.dart';

class RecordService {
  // 싱글톤 패턴 구현
  static final RecordService _instance = RecordService._internal();

  factory RecordService() => _instance;

  RecordService._internal();

  AppDatabase get _database => DatabaseService().database;

  // GameRecord 형태로 모든 기록 가져오기
  Future<List<GameRecord>> getAllRecords() async {
    try {
      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Getting all database records...');
        }
      }
      final dbRecords = await _database.getAllRecords();
      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Found ${dbRecords.length} database records');
        }
      }

      final gameRecords = <GameRecord>[];

      for (final record in dbRecords) {
        final gameRecord = await DatabaseService().convertRecordToGameRecord(
          record,
        );
        if (gameRecord != null) {
          gameRecords.add(gameRecord);
        }
      }

      // 날짜 기준으로 내림차순 정렬 (최신 기록이 위로)
      gameRecords.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      if (kDebugMode) {
        if (kDebugMode) {
          print(
            'RecordService: Converted ${gameRecords.length} records to GameRecord objects',
          );
        }
      }

      return gameRecords;
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error loading records: $e');
        }
      }
      return [];
    }
  }

  // Database 형태로 모든 기록 가져오기
  Future<List<Record>> getAllDatabaseRecords() async {
    try {
      return await _database.getAllRecords();
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error loading database records: $e');
        }
      }
      return [];
    }
  }

  // 즐겨찾기 기록만 가져오기
  Future<List<Record>> getFavoriteRecords() async {
    try {
      return await _database.getFavoriteRecords();
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error loading favorite records: $e');
        }
      }
      return [];
    }
  }

  // 특정 날짜의 기록 가져오기
  Future<List<Record>> getRecordsByDate(DateTime date) async {
    try {
      return await _database.getRecordsByDate(date);
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error loading records by date: $e');
        }
      }
      return [];
    }
  }

  // 특정 팀의 기록 가져오기
  Future<List<Record>> getRecordsByTeam(String teamId) async {
    try {
      return await _database.getRecordsByTeam(teamId);
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error loading records by team: $e');
        }
      }
      return [];
    }
  }

  // 새 기록 추가
  Future<int> addRecord(GameRecordForm form) async {
    try {
      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Starting addRecord...');
        }
      }
      if (kDebugMode) {
        if (kDebugMode) {
          print(
            'RecordService: Form data - DateTime: ${form.gameDateTime}, Stadium: ${form.stadiumId}, HomeTeam: ${form.homeTeamId}, AwayTeam: ${form.awayTeamId}',
          );
        }
      }
      if (kDebugMode) {
        if (kDebugMode) {
          print(
            'RecordService: Form scores - Home: ${form.homeScore}, Away: ${form.awayScore}',
          );
        }
      }
      if (kDebugMode) {
        if (kDebugMode) {
          print(
            'RecordService: Form extras - Seat: ${form.seatInfo}, Comment: ${form.comment}, Favorite: ${form.isFavorite}, Canceled: ${form.canceled}',
          );
        }
      }

      // 필수 필드 검증
      if (!form.isValid) {
        if (kDebugMode) {
          if (kDebugMode) {
            print('RecordService: Form validation failed');
          }
        }
        throw Exception('필수 정보가 누락되었습니다.');
      }

      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Form validation passed');
        }
      }

      // 이미지 파일 처리
      List<String> photosPaths = [];
      if (form.imagePaths != null && form.imagePaths!.isNotEmpty) {
        if (kDebugMode) {
          if (kDebugMode) {
            print(
              'RecordService: Processing ${form.imagePaths!.length} images',
            );
          }
        }
        for (final imagePath in form.imagePaths!) {
          if (kDebugMode) {
            if (kDebugMode) {
              print('RecordService: Processing image: $imagePath');
            }
          }
          final permanentPath = await _saveImagePermanently(imagePath);
          photosPaths.add(permanentPath);
          if (kDebugMode) {
            if (kDebugMode) {
              print('RecordService: Image saved to: $permanentPath');
            }
          }
        }
      } else if (form.imagePath != null) {
        // 하위 호환성을 위해 단일 이미지 경로도 처리
        if (kDebugMode) {
          if (kDebugMode) {
            print('RecordService: Processing single image: ${form.imagePath}');
          }
        }
        final permanentPath = await _saveImagePermanently(form.imagePath!);
        photosPaths.add(permanentPath);
        if (kDebugMode) {
          if (kDebugMode) {
            print('RecordService: Image saved to: $permanentPath');
          }
        }
      } else {
        if (kDebugMode) {
          if (kDebugMode) {
            print('RecordService: No images to process');
          }
        }
      }

      // 새 기록 생성
      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Creating record companion...');
        }
      }
      final companion = RecordsCompanion.insert(
        date: form.gameDateTime!,
        stadiumId: form.stadiumId!,
        homeTeamId: form.homeTeamId!,
        awayTeamId: form.awayTeamId!,
        homeScore: form.homeScore ?? 0,
        awayScore: form.awayScore ?? 0,
        canceled: Value(form.canceled),
        seat: Value(form.seatInfo),
        comment: Value(form.comment),
        photosJson: Value(
          photosPaths.isNotEmpty ? jsonEncode(photosPaths) : null,
        ),
        isFavorite: Value(form.isFavorite),
      );

      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Inserting record into database...');
        }
      }
      final recordId = await _database.insertRecord(companion);
      if (kDebugMode) {
        if (kDebugMode) {
          print(
            'RecordService: Record inserted successfully with ID: $recordId',
          );
        }
      }

      // 검증: 실제로 DB에 들어갔는지 확인
      final allRecords = await _database.getAllRecords();
      if (kDebugMode) {
        if (kDebugMode) {
          print(
            'RecordService: Total records in DB after insert: ${allRecords.length}',
          );
        }
      }

      final insertedRecord =
          allRecords.where((r) => r.id == recordId).firstOrNull;
      if (insertedRecord != null) {
        if (kDebugMode) {
          if (kDebugMode) {
            print(
              'RecordService: Verification successful - Record found in DB',
            );
          }
        }
        if (kDebugMode) {
          if (kDebugMode) {
            print(
              'RecordService: Inserted record details - Date: ${insertedRecord.date}, Stadium: ${insertedRecord.stadiumId}, Teams: ${insertedRecord.homeTeamId} vs ${insertedRecord.awayTeamId}',
            );
          }
        }
      } else {
        if (kDebugMode) {
          if (kDebugMode) {
            print(
              'RecordService: WARNING - Record not found in DB after insert!',
            );
          }
        }
      }

      return recordId;
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error adding record: $e');
        }
      }
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error stack trace: ${StackTrace.current}');
        }
      }
      rethrow;
    }
  }

  // 기록 업데이트
  Future<bool> updateRecord(int id, GameRecordForm form) async {
    try {
      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Starting updateRecord for ID: $id');
        }
      }

      final existingRecord = await _getRecordById(id);
      if (existingRecord == null) {
        if (kDebugMode) {
          if (kDebugMode) {
            print('RecordService: Record not found for ID: $id');
          }
        }
        throw Exception('Record not found');
      }

      if (kDebugMode) {
        if (kDebugMode) {
          print(
            'RecordService: Found existing record, proceeding with update...',
          );
        }
      }

      // 이미지 처리
      List<String> photosPaths = [];

      // 기존 이미지 경로들 유지
      if (existingRecord.photosJson != null) {
        try {
          final existingPhotos = jsonDecode(existingRecord.photosJson!) as List;
          photosPaths =
              existingPhotos.map((photo) => photo.toString()).toList();
          if (kDebugMode) {
            if (kDebugMode) {
              print(
                'RecordService: Loaded ${photosPaths.length} existing photos',
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            if (kDebugMode) {
              print('RecordService: Error parsing existing photos JSON: $e');
            }
          }
        }
      }

      // 새로운 이미지들 추가
      if (form.imagePaths != null && form.imagePaths!.isNotEmpty) {
        if (kDebugMode) {
          if (kDebugMode) {
            print(
              'RecordService: Processing ${form.imagePaths!.length} new images',
            );
          }
        }
        for (final imagePath in form.imagePaths!) {
          if (!imagePath.startsWith('/data/')) {
            final permanentPath = await _saveImagePermanently(imagePath);
            photosPaths.add(permanentPath);
            if (kDebugMode) {
              if (kDebugMode) {
                print('RecordService: Added new image: $permanentPath');
              }
            }
          } else {
            // 이미 영구 저장된 경로인 경우 그대로 유지
            if (!photosPaths.contains(imagePath)) {
              photosPaths.add(imagePath);
            }
          }
        }
      } else if (form.imagePath != null &&
          !form.imagePath!.startsWith('/data/')) {
        // 하위 호환성: 단일 이미지 처리
        final permanentPath = await _saveImagePermanently(form.imagePath!);
        photosPaths.add(permanentPath);
        if (kDebugMode) {
          if (kDebugMode) {
            print('RecordService: Added single new image: $permanentPath');
          }
        }
      }

      // 업데이트된 기록 생성
      final updatedRecord = RecordsCompanion(
        id: Value(id),
        date: Value(form.gameDateTime!),
        stadiumId: Value(form.stadiumId!),
        homeTeamId: Value(form.homeTeamId!),
        awayTeamId: Value(form.awayTeamId!),
        homeScore: Value(form.homeScore ?? 0),
        awayScore: Value(form.awayScore ?? 0),
        canceled: Value(form.canceled),
        seat: Value(form.seatInfo),
        comment: Value(form.comment),
        photosJson: Value(
          photosPaths.isNotEmpty ? jsonEncode(photosPaths) : null,
        ),
        isFavorite: Value(form.isFavorite),
        createdAt: Value(existingRecord.createdAt),
      );

      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Updating record in database...');
        }
      }
      final success = await _database.updateRecord(updatedRecord);
      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Update result: $success');
        }
      }

      // 업데이트 후 확인
      if (success) {
        final updatedRecordFromDb = await _getRecordById(id);
        if (updatedRecordFromDb != null) {
          if (kDebugMode) {
            if (kDebugMode) {
              print(
                'RecordService: Verification - Record updated successfully',
              );
            }
          }
          if (kDebugMode) {
            if (kDebugMode) {
              print('  - Stadium: ${updatedRecordFromDb.stadiumId}');
            }
          }
          if (kDebugMode) {
            if (kDebugMode) {
              print(
                '  - Teams: ${updatedRecordFromDb.homeTeamId} vs ${updatedRecordFromDb.awayTeamId}',
              );
            }
          }
          if (kDebugMode) {
            if (kDebugMode) {
              print(
                '  - Score: ${updatedRecordFromDb.homeScore}-${updatedRecordFromDb.awayScore}',
              );
            }
          }
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error updating record: $e');
        }
      }
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error stack trace: ${StackTrace.current}');
        }
      }
      return false;
    }
  }

  // 기록 삭제
  Future<bool> deleteRecord(int id) async {
    try {
      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Deleting record ID: $id');
        }
      }

      final deletedCount = await _database.deleteRecord(id);
      return deletedCount > 0;
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error deleting record: $e');
        }
      }
      return false;
    }
  }

  // 즐겨찾기 토글
  Future<bool> toggleFavorite(int id) async {
    try {
      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Toggling favorite for record ID: $id');
        }
      }

      final record = await _getRecordById(id);
      if (record == null) {
        if (kDebugMode) {
          if (kDebugMode) {
            print('RecordService: Record not found for ID: $id');
          }
        }
        return false;
      }

      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Current favorite status: ${record.isFavorite}');
        }
      }
      final newFavoriteStatus = !record.isFavorite;
      if (kDebugMode) {
        if (kDebugMode) {
          print(
            'RecordService: New favorite status will be: $newFavoriteStatus',
          );
        }
      }

      final updatedRecord = RecordsCompanion(
        id: Value(id),
        date: Value(record.date),
        stadiumId: Value(record.stadiumId),
        homeTeamId: Value(record.homeTeamId),
        awayTeamId: Value(record.awayTeamId),
        homeScore: Value(record.homeScore),
        awayScore: Value(record.awayScore),
        canceled: Value(record.canceled),
        seat: Value(record.seat),
        comment: Value(record.comment),
        photosJson: Value(record.photosJson),
        isFavorite: Value(newFavoriteStatus),
        createdAt: Value(record.createdAt),
      );

      final success = await _database.updateRecord(updatedRecord);
      if (kDebugMode) {
        if (kDebugMode) {
          print('RecordService: Update result: $success');
        }
      }

      // 업데이트 후 확인
      if (success) {
        final updatedRecordFromDb = await _getRecordById(id);
        if (updatedRecordFromDb != null) {
          if (kDebugMode) {
            if (kDebugMode) {
              print(
                'RecordService: Verification - DB now shows favorite status: ${updatedRecordFromDb.isFavorite}',
              );
            }
          }
        }
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error toggling favorite: $e');
        }
      }
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error stack trace: ${StackTrace.current}');
        }
      }
      return false;
    }
  }

  // 통계 관련 메서드
  Future<Map<String, int>> getStats(String myTeamId) async {
    try {
      final winCount = await _database.getWinCount(myTeamId);
      final loseCount = await _database.getLoseCount(myTeamId);
      final totalCount = await _database.getTotalGameCount(myTeamId);

      return {'win': winCount, 'lose': loseCount, 'total': totalCount};
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error getting stats: $e');
        }
      }
      return {'win': 0, 'lose': 0, 'total': 0};
    }
  }

  // ID로 기록 조회 (public 메서드)
  Future<GameRecord?> getRecordById(int id) async {
    try {
      final record = await _getRecordById(id);
      if (record == null) return null;

      return await DatabaseService().convertRecordToGameRecord(record);
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error getting record by ID: $e');
        }
      }
      return null;
    }
  }

  // ID로 기록 조회 (내부 메서드)
  Future<Record?> _getRecordById(int id) async {
    final records = await _database.getAllRecords();
    try {
      return records.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // 이미지 영구 저장
  Future<String> _saveImagePermanently(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${directory.path}/record_images');

    // 이미지 디렉토리 생성
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // 파일 확장자 추출
    final extension = sourcePath.split('.').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // 새 파일 경로
    final newPath = '${imagesDir.path}/record_$timestamp.$extension';

    // 파일 복사
    final sourceFile = File(sourcePath);
    await sourceFile.copy(newPath);

    return newPath;
  }
}

import 'package:flutter/foundation.dart';
import '../lib/services/database_service.dart';

void main() async {
  if (kDebugMode) print('데이터베이스 테스트 시작');

  try {
    final dbService = DatabaseService();
    await dbService.initialize();
    if (kDebugMode) print('데이터베이스 초기화 완료');

    await dbService.printDatabaseStatus();

    // 각 테이블별 상세 데이터 확인
    await dbService.printAllTeams();
    await dbService.printAllStadiums();
    await dbService.printAllRecords();

    if (kDebugMode) print('테스트 완료');
    if (kDebugMode) print('데이터베이스 연결 종료');
  } catch (e) {
    if (kDebugMode) print('테스트 실패: $e');
  }
}

import 'dart:io';
import 'package:seungyo/services/database_service.dart';

void main() async {
  print('데이터베이스 테스트 시작...');
  
  try {
    final dbService = DatabaseService();
    await dbService.initialize();
    print('✓ 데이터베이스 초기화 성공');
    
    await dbService.printDatabaseStatus();
    
    // 각 테이블별 상세 데이터 확인
    await dbService.printAllTeams();
    await dbService.printAllStadiums();
    await dbService.printAllRecords();
    
  } catch (e, stackTrace) {
    print('✗ 데이터베이스 테스트 실패: $e');
    print('Stack trace: $stackTrace');
  }
  
  print('데이터베이스 테스트 완료');
  exit(0);
}

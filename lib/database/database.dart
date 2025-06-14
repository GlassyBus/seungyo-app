import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';

part 'database.g.dart';

// 팀 테이블
@DataClassName('Team')
class Teams extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get code => text()();

  TextColumn get emblem => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// 경기장 테이블
@DataClassName('Stadium')
class Stadiums extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get city => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// 직관 기록 테이블
@DataClassName('Record')
class Records extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get date => dateTime()();

  TextColumn get stadiumId => text().references(Stadiums, #id)();

  TextColumn get homeTeamId => text().references(Teams, #id)();

  TextColumn get awayTeamId => text().references(Teams, #id)();

  IntColumn get homeScore => integer()();

  IntColumn get awayScore => integer()();

  BoolColumn get canceled => boolean().withDefault(const Constant(false))();

  TextColumn get seat => text().nullable()();

  TextColumn get comment => text().nullable()();

  TextColumn get photosJson => text().nullable()(); // JSON 배열로 저장
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Teams, Stadiums, Records])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  // 팀 DAO
  Future<List<Team>> getAllTeams() => select(teams).get();

  Future<Team?> getTeamById(String id) => (select(teams)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertTeam(TeamsCompanion team) => into(teams).insert(team);

  // 경기장 DAO
  Future<List<Stadium>> getAllStadiums() => select(stadiums).get();

  Future<Stadium?> getStadiumById(String id) => (select(stadiums)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int> insertStadium(StadiumsCompanion stadium) => into(stadiums).insert(stadium);

  // 직관 기록 DAO
  Future<List<Record>> getAllRecords() => select(records).get();

  Future<List<Record>> getFavoriteRecords() => (select(records)..where((r) => r.isFavorite.equals(true))).get();

  Future<List<Record>> getRecordsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(records)..where((r) => r.date.isBetween(Variable(startOfDay), Variable(endOfDay)))).get();
  }

  Future<List<Record>> getRecordsByTeam(String teamId) {
    return (select(records)..where((r) => r.homeTeamId.equals(teamId) | r.awayTeamId.equals(teamId))).get();
  }

  Future<int> insertRecord(RecordsCompanion record) => into(records).insert(record);

  Future<bool> updateRecord(RecordsCompanion record) => update(records).replace(record);

  Future<int> deleteRecord(int id) => (delete(records)..where((r) => r.id.equals(id))).go();

  // 통계 관련 메서드
  Future<int> getWinCount(String myTeamId) async {
    final query = select(records)..where(
      (r) =>
          (r.homeTeamId.equals(myTeamId) & r.homeScore.isBiggerThan(r.awayScore)) |
          (r.awayTeamId.equals(myTeamId) & r.awayScore.isBiggerThan(r.homeScore)),
    );
    final winRecords = await query.get();
    return winRecords.length;
  }

  Future<int> getLoseCount(String myTeamId) async {
    final query = select(records)..where(
      (r) =>
          (r.homeTeamId.equals(myTeamId) & r.homeScore.isSmallerThan(r.awayScore)) |
          (r.awayTeamId.equals(myTeamId) & r.awayScore.isSmallerThan(r.homeScore)),
    );
    final loseRecords = await query.get();
    return loseRecords.length;
  }

  Future<int> getTotalGameCount(String myTeamId) async {
    final totalRecords = await getRecordsByTeam(myTeamId);
    return totalRecords.length;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Android에서 SQLite3 문제 해결을 위한 설정
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'seungyo.db'));
    
    return NativeDatabase.createInBackground(file, logStatements: true);
  });
}

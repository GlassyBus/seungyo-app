import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// 팀 테이블
@DataClassName('Team')
class Teams extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get code => text()();
  TextColumn get emblem => text().nullable()();
}

// 경기장 테이블
@DataClassName('Stadium')
class Stadiums extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get city => text().nullable()();
}

// 직관 기록 테이블
@DataClassName('Record')
class Records extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get stadiumId => integer().references(Stadiums, #id)();
  IntColumn get homeTeamId => integer().references(Teams, #id)();
  IntColumn get awayTeamId => integer().references(Teams, #id)();
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
  int get schemaVersion => 1;

  // 팀 DAO
  Future<List<Team>> getAllTeams() => select(teams).get();
  Future<Team?> getTeamById(int id) => (select(teams)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<int> insertTeam(TeamsCompanion team) => into(teams).insert(team);

  // 경기장 DAO
  Future<List<Stadium>> getAllStadiums() => select(stadiums).get();
  Future<Stadium?> getStadiumById(int id) => (select(stadiums)..where((s) => s.id.equals(id))).getSingleOrNull();
  Future<int> insertStadium(StadiumsCompanion stadium) => into(stadiums).insert(stadium);

  // 직관 기록 DAO
  Future<List<Record>> getAllRecords() => select(records).get();
  Future<List<Record>> getFavoriteRecords() => (select(records)..where((r) => r.isFavorite.equals(true))).get();
  Future<List<Record>> getRecordsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(records)
      ..where((r) => r.date.isBetween(Variable(startOfDay), Variable(endOfDay))))
        .get();
  }
  
  Future<List<Record>> getRecordsByTeam(int teamId) {
    return (select(records)
      ..where((r) => r.homeTeamId.equals(teamId) | r.awayTeamId.equals(teamId)))
        .get();
  }

  Future<int> insertRecord(RecordsCompanion record) => into(records).insert(record);
  Future<bool> updateRecord(RecordsCompanion record) => update(records).replace(record);
  Future<int> deleteRecord(int id) => (delete(records)..where((r) => r.id.equals(id))).go();

  // 통계 관련 메서드
  Future<int> getWinCount(int myTeamId) async {
    final query = select(records)
      ..where((r) => 
        (r.homeTeamId.equals(myTeamId) & r.homeScore.isBiggerThan(r.awayScore)) |
        (r.awayTeamId.equals(myTeamId) & r.awayScore.isBiggerThan(r.homeScore))
      );
    final winRecords = await query.get();
    return winRecords.length;
  }

  Future<int> getLoseCount(int myTeamId) async {
    final query = select(records)
      ..where((r) => 
        (r.homeTeamId.equals(myTeamId) & r.homeScore.isSmallerThan(r.awayScore)) |
        (r.awayTeamId.equals(myTeamId) & r.awayScore.isSmallerThan(r.homeScore))
      );
    final loseRecords = await query.get();
    return loseRecords.length;
  }

  Future<int> getTotalGameCount(int myTeamId) async {
    final totalRecords = await getRecordsByTeam(myTeamId);
    return totalRecords.length;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'seungyo.db'));
    return NativeDatabase(file);
  });
}

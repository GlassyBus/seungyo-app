// import 'package:drift/drift.dart';
// import 'package:drift/native.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
//
// // part 'app_database.g.dart';
//
// class Posts extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get content => text()();
//   // 이미지 파일 경로 저장 (실제 파일은 path_provider를 통해 관리)
//   TextColumn get imagePath => text().nullable()();
//   DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
// }
//
// @DriftDatabase(tables: [Posts])
// class AppDatabase extends _$AppDatabase {
//   AppDatabase() : super(_openConnection());
//
//   @override
//   int get schemaVersion => 1;
//
// // CRUD 등 필요한 메서드를 추가할 수 있음.
// }
//
// LazyDatabase _openConnection() {
//   return LazyDatabase(() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final dbPath = p.join(directory.path, 'app_db.sqlite');
//     return NativeDatabase(File(dbPath));
//   });
// }

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TeamsTable extends Teams with TableInfo<$TeamsTable, Team> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;

  $TeamsTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emblemMeta = const VerificationMeta('emblem');
  @override
  late final GeneratedColumn<String> emblem = GeneratedColumn<String>(
    'emblem',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );

  @override
  List<GeneratedColumn> get $columns => [id, name, code, emblem];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  String get actualTableName => $name;
  static const String $name = 'teams';

  @override
  VerificationContext validateIntegrity(Insertable<Team> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(_codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('emblem')) {
      context.handle(_emblemMeta, emblem.isAcceptableOrUnknown(data['emblem']!, _emblemMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  @override
  Team map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Team(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      code: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      emblem: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}emblem']),
    );
  }

  @override
  $TeamsTable createAlias(String alias) {
    return $TeamsTable(attachedDatabase, alias);
  }
}

class Team extends DataClass implements Insertable<Team> {
  final String id;
  final String name;
  final String code;
  final String? emblem;

  const Team({required this.id, required this.name, required this.code, this.emblem});

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || emblem != null) {
      map['emblem'] = Variable<String>(emblem);
    }
    return map;
  }

  TeamsCompanion toCompanion(bool nullToAbsent) {
    return TeamsCompanion(
      id: Value(id),
      name: Value(name),
      code: Value(code),
      emblem: emblem == null && nullToAbsent ? const Value.absent() : Value(emblem),
    );
  }

  factory Team.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Team(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      emblem: serializer.fromJson<String?>(json['emblem']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'emblem': serializer.toJson<String?>(emblem),
    };
  }

  Team copyWith({String? id, String? name, String? code, Value<String?> emblem = const Value.absent()}) => Team(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
    emblem: emblem.present ? emblem.value : this.emblem,
  );

  Team copyWithCompanion(TeamsCompanion data) {
    return Team(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      emblem: data.emblem.present ? data.emblem.value : this.emblem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Team(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('emblem: $emblem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, code, emblem);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Team &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.emblem == this.emblem);
}

class TeamsCompanion extends UpdateCompanion<Team> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> code;
  final Value<String?> emblem;
  final Value<int> rowid;

  const TeamsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.emblem = const Value.absent(),
    this.rowid = const Value.absent(),
  });

  TeamsCompanion.insert({
    required String id,
    required String name,
    required String code,
    this.emblem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       code = Value(code);

  static Insertable<Team> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? emblem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (emblem != null) 'emblem': emblem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? code,
    Value<String?>? emblem,
    Value<int>? rowid,
  }) {
    return TeamsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      emblem: emblem ?? this.emblem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (emblem.present) {
      map['emblem'] = Variable<String>(emblem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('emblem: $emblem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StadiumsTable extends Stadiums with TableInfo<$StadiumsTable, Stadium> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;

  $StadiumsTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );

  @override
  List<GeneratedColumn> get $columns => [id, name, city];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  String get actualTableName => $name;
  static const String $name = 'stadiums';

  @override
  VerificationContext validateIntegrity(Insertable<Stadium> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('city')) {
      context.handle(_cityMeta, city.isAcceptableOrUnknown(data['city']!, _cityMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  @override
  Stadium map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Stadium(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      city: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}city']),
    );
  }

  @override
  $StadiumsTable createAlias(String alias) {
    return $StadiumsTable(attachedDatabase, alias);
  }
}

class Stadium extends DataClass implements Insertable<Stadium> {
  final String id;
  final String name;
  final String? city;

  const Stadium({required this.id, required this.name, this.city});

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    return map;
  }

  StadiumsCompanion toCompanion(bool nullToAbsent) {
    return StadiumsCompanion(
      id: Value(id),
      name: Value(name),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
    );
  }

  factory Stadium.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Stadium(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      city: serializer.fromJson<String?>(json['city']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'city': serializer.toJson<String?>(city),
    };
  }

  Stadium copyWith({String? id, String? name, Value<String?> city = const Value.absent()}) =>
      Stadium(id: id ?? this.id, name: name ?? this.name, city: city.present ? city.value : this.city);

  Stadium copyWithCompanion(StadiumsCompanion data) {
    return Stadium(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      city: data.city.present ? data.city.value : this.city,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Stadium(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('city: $city')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, city);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stadium && other.id == this.id && other.name == this.name && other.city == this.city);
}

class StadiumsCompanion extends UpdateCompanion<Stadium> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> city;
  final Value<int> rowid;

  const StadiumsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.city = const Value.absent(),
    this.rowid = const Value.absent(),
  });

  StadiumsCompanion.insert({
    required String id,
    required String name,
    this.city = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);

  static Insertable<Stadium> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? city,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (city != null) 'city': city,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StadiumsCompanion copyWith({Value<String>? id, Value<String>? name, Value<String?>? city, Value<int>? rowid}) {
    return StadiumsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StadiumsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('city: $city, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecordsTable extends Records with TableInfo<$RecordsTable, Record> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;

  $RecordsTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stadiumIdMeta = const VerificationMeta('stadiumId');
  @override
  late final GeneratedColumn<String> stadiumId = GeneratedColumn<String>(
    'stadium_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES stadiums (id)'),
  );
  static const VerificationMeta _homeTeamIdMeta = const VerificationMeta('homeTeamId');
  @override
  late final GeneratedColumn<String> homeTeamId = GeneratedColumn<String>(
    'home_team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES teams (id)'),
  );
  static const VerificationMeta _awayTeamIdMeta = const VerificationMeta('awayTeamId');
  @override
  late final GeneratedColumn<String> awayTeamId = GeneratedColumn<String>(
    'away_team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES teams (id)'),
  );
  static const VerificationMeta _homeScoreMeta = const VerificationMeta('homeScore');
  @override
  late final GeneratedColumn<int> homeScore = GeneratedColumn<int>(
    'home_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _awayScoreMeta = const VerificationMeta('awayScore');
  @override
  late final GeneratedColumn<int> awayScore = GeneratedColumn<int>(
    'away_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canceledMeta = const VerificationMeta('canceled');
  @override
  late final GeneratedColumn<bool> canceled = GeneratedColumn<bool>(
    'canceled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("canceled" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _seatMeta = const VerificationMeta('seat');
  @override
  late final GeneratedColumn<String> seat = GeneratedColumn<String>(
    'seat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photosJsonMeta = const VerificationMeta('photosJson');
  @override
  late final GeneratedColumn<String> photosJson = GeneratedColumn<String>(
    'photos_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );

  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    stadiumId,
    homeTeamId,
    awayTeamId,
    homeScore,
    awayScore,
    canceled,
    seat,
    comment,
    photosJson,
    isFavorite,
    createdAt,
  ];

  @override
  String get aliasedName => _alias ?? actualTableName;

  @override
  String get actualTableName => $name;
  static const String $name = 'records';

  @override
  VerificationContext validateIntegrity(Insertable<Record> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('stadium_id')) {
      context.handle(_stadiumIdMeta, stadiumId.isAcceptableOrUnknown(data['stadium_id']!, _stadiumIdMeta));
    } else if (isInserting) {
      context.missing(_stadiumIdMeta);
    }
    if (data.containsKey('home_team_id')) {
      context.handle(_homeTeamIdMeta, homeTeamId.isAcceptableOrUnknown(data['home_team_id']!, _homeTeamIdMeta));
    } else if (isInserting) {
      context.missing(_homeTeamIdMeta);
    }
    if (data.containsKey('away_team_id')) {
      context.handle(_awayTeamIdMeta, awayTeamId.isAcceptableOrUnknown(data['away_team_id']!, _awayTeamIdMeta));
    } else if (isInserting) {
      context.missing(_awayTeamIdMeta);
    }
    if (data.containsKey('home_score')) {
      context.handle(_homeScoreMeta, homeScore.isAcceptableOrUnknown(data['home_score']!, _homeScoreMeta));
    } else if (isInserting) {
      context.missing(_homeScoreMeta);
    }
    if (data.containsKey('away_score')) {
      context.handle(_awayScoreMeta, awayScore.isAcceptableOrUnknown(data['away_score']!, _awayScoreMeta));
    } else if (isInserting) {
      context.missing(_awayScoreMeta);
    }
    if (data.containsKey('canceled')) {
      context.handle(_canceledMeta, canceled.isAcceptableOrUnknown(data['canceled']!, _canceledMeta));
    }
    if (data.containsKey('seat')) {
      context.handle(_seatMeta, seat.isAcceptableOrUnknown(data['seat']!, _seatMeta));
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta, comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    if (data.containsKey('photos_json')) {
      context.handle(_photosJsonMeta, photosJson.isAcceptableOrUnknown(data['photos_json']!, _photosJsonMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(_isFavoriteMeta, isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  @override
  Record map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Record(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      stadiumId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}stadium_id'])!,
      homeTeamId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}home_team_id'])!,
      awayTeamId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}away_team_id'])!,
      homeScore: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}home_score'])!,
      awayScore: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}away_score'])!,
      canceled: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}canceled'])!,
      seat: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}seat']),
      comment: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}comment']),
      photosJson: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}photos_json']),
      isFavorite: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RecordsTable createAlias(String alias) {
    return $RecordsTable(attachedDatabase, alias);
  }
}

class Record extends DataClass implements Insertable<Record> {
  final int id;
  final DateTime date;
  final String stadiumId;
  final String homeTeamId;
  final String awayTeamId;
  final int homeScore;
  final int awayScore;
  final bool canceled;
  final String? seat;
  final String? comment;
  final String? photosJson;
  final bool isFavorite;
  final DateTime createdAt;

  const Record({
    required this.id,
    required this.date,
    required this.stadiumId,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeScore,
    required this.awayScore,
    required this.canceled,
    this.seat,
    this.comment,
    this.photosJson,
    required this.isFavorite,
    required this.createdAt,
  });

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['stadium_id'] = Variable<String>(stadiumId);
    map['home_team_id'] = Variable<String>(homeTeamId);
    map['away_team_id'] = Variable<String>(awayTeamId);
    map['home_score'] = Variable<int>(homeScore);
    map['away_score'] = Variable<int>(awayScore);
    map['canceled'] = Variable<bool>(canceled);
    if (!nullToAbsent || seat != null) {
      map['seat'] = Variable<String>(seat);
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    if (!nullToAbsent || photosJson != null) {
      map['photos_json'] = Variable<String>(photosJson);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecordsCompanion toCompanion(bool nullToAbsent) {
    return RecordsCompanion(
      id: Value(id),
      date: Value(date),
      stadiumId: Value(stadiumId),
      homeTeamId: Value(homeTeamId),
      awayTeamId: Value(awayTeamId),
      homeScore: Value(homeScore),
      awayScore: Value(awayScore),
      canceled: Value(canceled),
      seat: seat == null && nullToAbsent ? const Value.absent() : Value(seat),
      comment: comment == null && nullToAbsent ? const Value.absent() : Value(comment),
      photosJson: photosJson == null && nullToAbsent ? const Value.absent() : Value(photosJson),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
    );
  }

  factory Record.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Record(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      stadiumId: serializer.fromJson<String>(json['stadiumId']),
      homeTeamId: serializer.fromJson<String>(json['homeTeamId']),
      awayTeamId: serializer.fromJson<String>(json['awayTeamId']),
      homeScore: serializer.fromJson<int>(json['homeScore']),
      awayScore: serializer.fromJson<int>(json['awayScore']),
      canceled: serializer.fromJson<bool>(json['canceled']),
      seat: serializer.fromJson<String?>(json['seat']),
      comment: serializer.fromJson<String?>(json['comment']),
      photosJson: serializer.fromJson<String?>(json['photosJson']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'stadiumId': serializer.toJson<String>(stadiumId),
      'homeTeamId': serializer.toJson<String>(homeTeamId),
      'awayTeamId': serializer.toJson<String>(awayTeamId),
      'homeScore': serializer.toJson<int>(homeScore),
      'awayScore': serializer.toJson<int>(awayScore),
      'canceled': serializer.toJson<bool>(canceled),
      'seat': serializer.toJson<String?>(seat),
      'comment': serializer.toJson<String?>(comment),
      'photosJson': serializer.toJson<String?>(photosJson),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Record copyWith({
    int? id,
    DateTime? date,
    String? stadiumId,
    String? homeTeamId,
    String? awayTeamId,
    int? homeScore,
    int? awayScore,
    bool? canceled,
    Value<String?> seat = const Value.absent(),
    Value<String?> comment = const Value.absent(),
    Value<String?> photosJson = const Value.absent(),
    bool? isFavorite,
    DateTime? createdAt,
  }) => Record(
    id: id ?? this.id,
    date: date ?? this.date,
    stadiumId: stadiumId ?? this.stadiumId,
    homeTeamId: homeTeamId ?? this.homeTeamId,
    awayTeamId: awayTeamId ?? this.awayTeamId,
    homeScore: homeScore ?? this.homeScore,
    awayScore: awayScore ?? this.awayScore,
    canceled: canceled ?? this.canceled,
    seat: seat.present ? seat.value : this.seat,
    comment: comment.present ? comment.value : this.comment,
    photosJson: photosJson.present ? photosJson.value : this.photosJson,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
  );

  Record copyWithCompanion(RecordsCompanion data) {
    return Record(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      stadiumId: data.stadiumId.present ? data.stadiumId.value : this.stadiumId,
      homeTeamId: data.homeTeamId.present ? data.homeTeamId.value : this.homeTeamId,
      awayTeamId: data.awayTeamId.present ? data.awayTeamId.value : this.awayTeamId,
      homeScore: data.homeScore.present ? data.homeScore.value : this.homeScore,
      awayScore: data.awayScore.present ? data.awayScore.value : this.awayScore,
      canceled: data.canceled.present ? data.canceled.value : this.canceled,
      seat: data.seat.present ? data.seat.value : this.seat,
      comment: data.comment.present ? data.comment.value : this.comment,
      photosJson: data.photosJson.present ? data.photosJson.value : this.photosJson,
      isFavorite: data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Record(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('stadiumId: $stadiumId, ')
          ..write('homeTeamId: $homeTeamId, ')
          ..write('awayTeamId: $awayTeamId, ')
          ..write('homeScore: $homeScore, ')
          ..write('awayScore: $awayScore, ')
          ..write('canceled: $canceled, ')
          ..write('seat: $seat, ')
          ..write('comment: $comment, ')
          ..write('photosJson: $photosJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    stadiumId,
    homeTeamId,
    awayTeamId,
    homeScore,
    awayScore,
    canceled,
    seat,
    comment,
    photosJson,
    isFavorite,
    createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Record &&
          other.id == this.id &&
          other.date == this.date &&
          other.stadiumId == this.stadiumId &&
          other.homeTeamId == this.homeTeamId &&
          other.awayTeamId == this.awayTeamId &&
          other.homeScore == this.homeScore &&
          other.awayScore == this.awayScore &&
          other.canceled == this.canceled &&
          other.seat == this.seat &&
          other.comment == this.comment &&
          other.photosJson == this.photosJson &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt);
}

class RecordsCompanion extends UpdateCompanion<Record> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> stadiumId;
  final Value<String> homeTeamId;
  final Value<String> awayTeamId;
  final Value<int> homeScore;
  final Value<int> awayScore;
  final Value<bool> canceled;
  final Value<String?> seat;
  final Value<String?> comment;
  final Value<String?> photosJson;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;

  const RecordsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.stadiumId = const Value.absent(),
    this.homeTeamId = const Value.absent(),
    this.awayTeamId = const Value.absent(),
    this.homeScore = const Value.absent(),
    this.awayScore = const Value.absent(),
    this.canceled = const Value.absent(),
    this.seat = const Value.absent(),
    this.comment = const Value.absent(),
    this.photosJson = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
  });

  RecordsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String stadiumId,
    required String homeTeamId,
    required String awayTeamId,
    required int homeScore,
    required int awayScore,
    this.canceled = const Value.absent(),
    this.seat = const Value.absent(),
    this.comment = const Value.absent(),
    this.photosJson = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : date = Value(date),
       stadiumId = Value(stadiumId),
       homeTeamId = Value(homeTeamId),
       awayTeamId = Value(awayTeamId),
       homeScore = Value(homeScore),
       awayScore = Value(awayScore);

  static Insertable<Record> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? stadiumId,
    Expression<String>? homeTeamId,
    Expression<String>? awayTeamId,
    Expression<int>? homeScore,
    Expression<int>? awayScore,
    Expression<bool>? canceled,
    Expression<String>? seat,
    Expression<String>? comment,
    Expression<String>? photosJson,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (stadiumId != null) 'stadium_id': stadiumId,
      if (homeTeamId != null) 'home_team_id': homeTeamId,
      if (awayTeamId != null) 'away_team_id': awayTeamId,
      if (homeScore != null) 'home_score': homeScore,
      if (awayScore != null) 'away_score': awayScore,
      if (canceled != null) 'canceled': canceled,
      if (seat != null) 'seat': seat,
      if (comment != null) 'comment': comment,
      if (photosJson != null) 'photos_json': photosJson,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecordsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? stadiumId,
    Value<String>? homeTeamId,
    Value<String>? awayTeamId,
    Value<int>? homeScore,
    Value<int>? awayScore,
    Value<bool>? canceled,
    Value<String?>? seat,
    Value<String?>? comment,
    Value<String?>? photosJson,
    Value<bool>? isFavorite,
    Value<DateTime>? createdAt,
  }) {
    return RecordsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      stadiumId: stadiumId ?? this.stadiumId,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      canceled: canceled ?? this.canceled,
      seat: seat ?? this.seat,
      comment: comment ?? this.comment,
      photosJson: photosJson ?? this.photosJson,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (stadiumId.present) {
      map['stadium_id'] = Variable<String>(stadiumId.value);
    }
    if (homeTeamId.present) {
      map['home_team_id'] = Variable<String>(homeTeamId.value);
    }
    if (awayTeamId.present) {
      map['away_team_id'] = Variable<String>(awayTeamId.value);
    }
    if (homeScore.present) {
      map['home_score'] = Variable<int>(homeScore.value);
    }
    if (awayScore.present) {
      map['away_score'] = Variable<int>(awayScore.value);
    }
    if (canceled.present) {
      map['canceled'] = Variable<bool>(canceled.value);
    }
    if (seat.present) {
      map['seat'] = Variable<String>(seat.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (photosJson.present) {
      map['photos_json'] = Variable<String>(photosJson.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('stadiumId: $stadiumId, ')
          ..write('homeTeamId: $homeTeamId, ')
          ..write('awayTeamId: $awayTeamId, ')
          ..write('homeScore: $homeScore, ')
          ..write('awayScore: $awayScore, ')
          ..write('canceled: $canceled, ')
          ..write('seat: $seat, ')
          ..write('comment: $comment, ')
          ..write('photosJson: $photosJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);

  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TeamsTable teams = $TeamsTable(this);
  late final $StadiumsTable stadiums = $StadiumsTable(this);
  late final $RecordsTable records = $RecordsTable(this);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [teams, stadiums, records];
}

typedef $$TeamsTableCreateCompanionBuilder =
    TeamsCompanion Function({
      required String id,
      required String name,
      required String code,
      Value<String?> emblem,
      Value<int> rowid,
    });
typedef $$TeamsTableUpdateCompanionBuilder =
    TeamsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> code,
      Value<String?> emblem,
      Value<int> rowid,
    });

class $$TeamsTableFilterComposer extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });

  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emblem =>
      $composableBuilder(column: $table.emblem, builder: (column) => ColumnFilters(column));
}

class $$TeamsTableOrderingComposer extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });

  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emblem =>
      $composableBuilder(column: $table.emblem, builder: (column) => ColumnOrderings(column));
}

class $$TeamsTableAnnotationComposer extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });

  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code => $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get emblem => $composableBuilder(column: $table.emblem, builder: (column) => column);
}

class $$TeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamsTable,
          Team,
          $$TeamsTableFilterComposer,
          $$TeamsTableOrderingComposer,
          $$TeamsTableAnnotationComposer,
          $$TeamsTableCreateCompanionBuilder,
          $$TeamsTableUpdateCompanionBuilder,
          (Team, BaseReferences<_$AppDatabase, $TeamsTable, Team>),
          Team,
          PrefetchHooks Function()
        > {
  $$TeamsTableTableManager(_$AppDatabase db, $TeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String?> emblem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion(id: id, name: name, code: code, emblem: emblem, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String code,
                Value<String?> emblem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion.insert(id: id, name: name, code: code, emblem: emblem, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamsTable,
      Team,
      $$TeamsTableFilterComposer,
      $$TeamsTableOrderingComposer,
      $$TeamsTableAnnotationComposer,
      $$TeamsTableCreateCompanionBuilder,
      $$TeamsTableUpdateCompanionBuilder,
      (Team, BaseReferences<_$AppDatabase, $TeamsTable, Team>),
      Team,
      PrefetchHooks Function()
    >;
typedef $$StadiumsTableCreateCompanionBuilder =
    StadiumsCompanion Function({required String id, required String name, Value<String?> city, Value<int> rowid});
typedef $$StadiumsTableUpdateCompanionBuilder =
    StadiumsCompanion Function({Value<String> id, Value<String> name, Value<String?> city, Value<int> rowid});

final class $$StadiumsTableReferences extends BaseReferences<_$AppDatabase, $StadiumsTable, Stadium> {
  $$StadiumsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecordsTable, List<Record>> _recordsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.records, aliasName: $_aliasNameGenerator(db.stadiums.id, db.records.stadiumId));

  $$RecordsTableProcessedTableManager get recordsRefs {
    final manager = $$RecordsTableTableManager(
      $_db,
      $_db.records,
    ).filter((f) => f.stadiumId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recordsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$StadiumsTableFilterComposer extends Composer<_$AppDatabase, $StadiumsTable> {
  $$StadiumsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });

  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get city => $composableBuilder(column: $table.city, builder: (column) => ColumnFilters(column));

  Expression<bool> recordsRefs(Expression<bool> Function($$RecordsTableFilterComposer f) f) {
    final $$RecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.records,
      getReferencedColumn: (t) => t.stadiumId,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$RecordsTableFilterComposer(
                $db: $db,
                $table: $db.records,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }
}

class $$StadiumsTableOrderingComposer extends Composer<_$AppDatabase, $StadiumsTable> {
  $$StadiumsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });

  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => ColumnOrderings(column));
}

class $$StadiumsTableAnnotationComposer extends Composer<_$AppDatabase, $StadiumsTable> {
  $$StadiumsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });

  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get city => $composableBuilder(column: $table.city, builder: (column) => column);

  Expression<T> recordsRefs<T extends Object>(Expression<T> Function($$RecordsTableAnnotationComposer a) f) {
    final $$RecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.records,
      getReferencedColumn: (t) => t.stadiumId,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$RecordsTableAnnotationComposer(
                $db: $db,
                $table: $db.records,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return f(composer);
  }
}

class $$StadiumsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StadiumsTable,
          Stadium,
          $$StadiumsTableFilterComposer,
          $$StadiumsTableOrderingComposer,
          $$StadiumsTableAnnotationComposer,
          $$StadiumsTableCreateCompanionBuilder,
          $$StadiumsTableUpdateCompanionBuilder,
          (Stadium, $$StadiumsTableReferences),
          Stadium,
          PrefetchHooks Function({bool recordsRefs})
        > {
  $$StadiumsTableTableManager(_$AppDatabase db, $StadiumsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$StadiumsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$StadiumsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$StadiumsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StadiumsCompanion(id: id, name: name, city: city, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> city = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StadiumsCompanion.insert(id: id, name: name, city: city, rowid: rowid),
          withReferenceMapper:
              (p0) => p0.map((e) => (e.readTable(table), $$StadiumsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({recordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (recordsRefs) db.records],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recordsRefs)
                    await $_getPrefetchedData<Stadium, $StadiumsTable, Record>(
                      currentTable: table,
                      referencedTable: $$StadiumsTableReferences._recordsRefsTable(db),
                      managerFromTypedResult: (p0) => $$StadiumsTableReferences(db, table, p0).recordsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where((e) => e.stadiumId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StadiumsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StadiumsTable,
      Stadium,
      $$StadiumsTableFilterComposer,
      $$StadiumsTableOrderingComposer,
      $$StadiumsTableAnnotationComposer,
      $$StadiumsTableCreateCompanionBuilder,
      $$StadiumsTableUpdateCompanionBuilder,
      (Stadium, $$StadiumsTableReferences),
      Stadium,
      PrefetchHooks Function({bool recordsRefs})
    >;
typedef $$RecordsTableCreateCompanionBuilder =
    RecordsCompanion Function({
      Value<int> id,
      required DateTime date,
      required String stadiumId,
      required String homeTeamId,
      required String awayTeamId,
      required int homeScore,
      required int awayScore,
      Value<bool> canceled,
      Value<String?> seat,
      Value<String?> comment,
      Value<String?> photosJson,
      Value<bool> isFavorite,
      Value<DateTime> createdAt,
    });
typedef $$RecordsTableUpdateCompanionBuilder =
    RecordsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> stadiumId,
      Value<String> homeTeamId,
      Value<String> awayTeamId,
      Value<int> homeScore,
      Value<int> awayScore,
      Value<bool> canceled,
      Value<String?> seat,
      Value<String?> comment,
      Value<String?> photosJson,
      Value<bool> isFavorite,
      Value<DateTime> createdAt,
    });

final class $$RecordsTableReferences extends BaseReferences<_$AppDatabase, $RecordsTable, Record> {
  $$RecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StadiumsTable _stadiumIdTable(_$AppDatabase db) =>
      db.stadiums.createAlias($_aliasNameGenerator(db.records.stadiumId, db.stadiums.id));

  $$StadiumsTableProcessedTableManager get stadiumId {
    final $_column = $_itemColumn<String>('stadium_id')!;

    final manager = $$StadiumsTableTableManager($_db, $_db.stadiums).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stadiumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TeamsTable _homeTeamIdTable(_$AppDatabase db) =>
      db.teams.createAlias($_aliasNameGenerator(db.records.homeTeamId, db.teams.id));

  $$TeamsTableProcessedTableManager get homeTeamId {
    final $_column = $_itemColumn<String>('home_team_id')!;

    final manager = $$TeamsTableTableManager($_db, $_db.teams).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_homeTeamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TeamsTable _awayTeamIdTable(_$AppDatabase db) =>
      db.teams.createAlias($_aliasNameGenerator(db.records.awayTeamId, db.teams.id));

  $$TeamsTableProcessedTableManager get awayTeamId {
    final $_column = $_itemColumn<String>('away_team_id')!;

    final manager = $$TeamsTableTableManager($_db, $_db.teams).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_awayTeamIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecordsTableFilterComposer extends Composer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });

  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get homeScore =>
      $composableBuilder(column: $table.homeScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get awayScore =>
      $composableBuilder(column: $table.awayScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canceled =>
      $composableBuilder(column: $table.canceled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seat => $composableBuilder(column: $table.seat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photosJson =>
      $composableBuilder(column: $table.photosJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite =>
      $composableBuilder(column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$StadiumsTableFilterComposer get stadiumId {
    final $$StadiumsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stadiumId,
      referencedTable: $db.stadiums,
      getReferencedColumn: (t) => t.id,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$StadiumsTableFilterComposer(
                $db: $db,
                $table: $db.stadiums,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }

  $$TeamsTableFilterComposer get homeTeamId {
    final $$TeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeTeamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$TeamsTableFilterComposer(
                $db: $db,
                $table: $db.teams,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }

  $$TeamsTableFilterComposer get awayTeamId {
    final $$TeamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.awayTeamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$TeamsTableFilterComposer(
                $db: $db,
                $table: $db.teams,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$RecordsTableOrderingComposer extends Composer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });

  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get homeScore =>
      $composableBuilder(column: $table.homeScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get awayScore =>
      $composableBuilder(column: $table.awayScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canceled =>
      $composableBuilder(column: $table.canceled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seat =>
      $composableBuilder(column: $table.seat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photosJson =>
      $composableBuilder(column: $table.photosJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite =>
      $composableBuilder(column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$StadiumsTableOrderingComposer get stadiumId {
    final $$StadiumsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stadiumId,
      referencedTable: $db.stadiums,
      getReferencedColumn: (t) => t.id,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$StadiumsTableOrderingComposer(
                $db: $db,
                $table: $db.stadiums,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }

  $$TeamsTableOrderingComposer get homeTeamId {
    final $$TeamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeTeamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$TeamsTableOrderingComposer(
                $db: $db,
                $table: $db.teams,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }

  $$TeamsTableOrderingComposer get awayTeamId {
    final $$TeamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.awayTeamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$TeamsTableOrderingComposer(
                $db: $db,
                $table: $db.teams,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$RecordsTableAnnotationComposer extends Composer<_$AppDatabase, $RecordsTable> {
  $$RecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });

  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get homeScore => $composableBuilder(column: $table.homeScore, builder: (column) => column);

  GeneratedColumn<int> get awayScore => $composableBuilder(column: $table.awayScore, builder: (column) => column);

  GeneratedColumn<bool> get canceled => $composableBuilder(column: $table.canceled, builder: (column) => column);

  GeneratedColumn<String> get seat => $composableBuilder(column: $table.seat, builder: (column) => column);

  GeneratedColumn<String> get comment => $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get photosJson => $composableBuilder(column: $table.photosJson, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StadiumsTableAnnotationComposer get stadiumId {
    final $$StadiumsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stadiumId,
      referencedTable: $db.stadiums,
      getReferencedColumn: (t) => t.id,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$StadiumsTableAnnotationComposer(
                $db: $db,
                $table: $db.stadiums,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }

  $$TeamsTableAnnotationComposer get homeTeamId {
    final $$TeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.homeTeamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$TeamsTableAnnotationComposer(
                $db: $db,
                $table: $db.teams,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }

  $$TeamsTableAnnotationComposer get awayTeamId {
    final $$TeamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.awayTeamId,
      referencedTable: $db.teams,
      getReferencedColumn: (t) => t.id,
      builder:
          (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
              $$TeamsTableAnnotationComposer(
                $db: $db,
                $table: $db.teams,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
              ),
    );
    return composer;
  }
}

class $$RecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecordsTable,
          Record,
          $$RecordsTableFilterComposer,
          $$RecordsTableOrderingComposer,
          $$RecordsTableAnnotationComposer,
          $$RecordsTableCreateCompanionBuilder,
          $$RecordsTableUpdateCompanionBuilder,
          (Record, $$RecordsTableReferences),
          Record,
          PrefetchHooks Function({bool stadiumId, bool homeTeamId, bool awayTeamId})
        > {
  $$RecordsTableTableManager(_$AppDatabase db, $RecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> stadiumId = const Value.absent(),
                Value<String> homeTeamId = const Value.absent(),
                Value<String> awayTeamId = const Value.absent(),
                Value<int> homeScore = const Value.absent(),
                Value<int> awayScore = const Value.absent(),
                Value<bool> canceled = const Value.absent(),
                Value<String?> seat = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String?> photosJson = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecordsCompanion(
                id: id,
                date: date,
                stadiumId: stadiumId,
                homeTeamId: homeTeamId,
                awayTeamId: awayTeamId,
                homeScore: homeScore,
                awayScore: awayScore,
                canceled: canceled,
                seat: seat,
                comment: comment,
                photosJson: photosJson,
                isFavorite: isFavorite,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String stadiumId,
                required String homeTeamId,
                required String awayTeamId,
                required int homeScore,
                required int awayScore,
                Value<bool> canceled = const Value.absent(),
                Value<String?> seat = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String?> photosJson = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecordsCompanion.insert(
                id: id,
                date: date,
                stadiumId: stadiumId,
                homeTeamId: homeTeamId,
                awayTeamId: awayTeamId,
                homeScore: homeScore,
                awayScore: awayScore,
                canceled: canceled,
                seat: seat,
                comment: comment,
                photosJson: photosJson,
                isFavorite: isFavorite,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) => p0.map((e) => (e.readTable(table), $$RecordsTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({stadiumId = false, homeTeamId = false, awayTeamId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (stadiumId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.stadiumId,
                            referencedTable: $$RecordsTableReferences._stadiumIdTable(db),
                            referencedColumn: $$RecordsTableReferences._stadiumIdTable(db).id,
                          )
                          as T;
                }
                if (homeTeamId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.homeTeamId,
                            referencedTable: $$RecordsTableReferences._homeTeamIdTable(db),
                            referencedColumn: $$RecordsTableReferences._homeTeamIdTable(db).id,
                          )
                          as T;
                }
                if (awayTeamId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.awayTeamId,
                            referencedTable: $$RecordsTableReferences._awayTeamIdTable(db),
                            referencedColumn: $$RecordsTableReferences._awayTeamIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecordsTable,
      Record,
      $$RecordsTableFilterComposer,
      $$RecordsTableOrderingComposer,
      $$RecordsTableAnnotationComposer,
      $$RecordsTableCreateCompanionBuilder,
      $$RecordsTableUpdateCompanionBuilder,
      (Record, $$RecordsTableReferences),
      Record,
      PrefetchHooks Function({bool stadiumId, bool homeTeamId, bool awayTeamId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;

  $AppDatabaseManager(this._db);

  $$TeamsTableTableManager get teams => $$TeamsTableTableManager(_db, _db.teams);

  $$StadiumsTableTableManager get stadiums => $$StadiumsTableTableManager(_db, _db.stadiums);

  $$RecordsTableTableManager get records => $$RecordsTableTableManager(_db, _db.records);
}

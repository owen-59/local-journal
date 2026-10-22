import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:journal/database.steps.dart';
import 'package:journal/models/entry.dart';
import 'package:journal/utils/string_list_converter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

const cacheTtl = Duration(days: 30);

EntriesCacheCompanion cacheEntryFromEntry(Entry entry) {
  return EntriesCacheCompanion(
    createdDate: Value(entry.datetime),
    body: Value(entry.body),
    tags: Value(entry.tags),
    images: Value(entry.images),
    lastCheckedAt: Value(DateTime.now()),
    longitude: Value.absentIfNull(entry.location?.longitude),
    latitude: Value.absentIfNull(entry.location?.latitude),
  );
}

class EntriesCache extends Table {
  DateTimeColumn get lastCheckedAt => dateTime()();
  DateTimeColumn get createdDate => dateTime()();
  TextColumn get body => text().nullable()();
  TextColumn get tags => text().map(const StringListConverter())();
  TextColumn get images => text().map(const StringListConverter()).nullable()();
  Column<double> get longitude => real().nullable()();
  Column<double> get latitude => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {createdDate};
}

@DriftDatabase(tables: [EntriesCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(onUpgrade: _schemaUpgrade);
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'journal_database',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}

extension Migrations on GeneratedDatabase {
  OnUpgrade get _schemaUpgrade => stepByStep(
    from1To2: (m, schema) async {
      await m.alterTable(
        TableMigration(
          schema.entriesCache,
          newColumns: [
            schema.entriesCache.longitude,
            schema.entriesCache.latitude,
          ],
        ),
      );
    },
    from2To3: (m, schema) async {
      await m.alterTable(
        TableMigration(
          schema.entriesCache,
          newColumns: [schema.entriesCache.images],
        ),
      );
    },
    from3To4: (m, schema) async {
      await m.alterTable(
        TableMigration(
          schema.entriesCache,
          newColumns: [schema.entriesCache.body],
        ),
      );
    },
  );
}

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:journal/models/entry.dart';
import 'package:journal/utils/string_list_converter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

EntriesCacheCompanion cacheEntryFromEntry(Entry entry) {
  return EntriesCacheCompanion(
    createdDate: Value(entry.datetime),
    tags: Value(entry.tags),
    lastCheckedAt: Value(DateTime.now()),
  );
}

class EntriesCache extends Table {
  DateTimeColumn get lastCheckedAt => dateTime()();
  DateTimeColumn get createdDate => dateTime().unique()();
  TextColumn get tags => text().map(const StringListConverter())();

  @override
  Set<Column<Object>> get primaryKey => {createdDate};
}

@DriftDatabase(tables: [EntriesCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'journal_database',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}

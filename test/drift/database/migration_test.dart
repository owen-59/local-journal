// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:journal/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journal/utils/string_list_converter.dart';
import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('migration from v1 to v2 does not corrupt data', () async {
    final oldEntriesCacheData = <v1.EntriesCacheData>[
      v1.EntriesCacheData(
        tags: StringListConverter().toSql(["test_tag", "test_tag_2"]),
        createdDate: 1000,
        lastCheckedAt: 50000,
      ),
    ];
    final expectedNewEntriesCacheData = <v2.EntriesCacheData>[
      v2.EntriesCacheData(
        tags: StringListConverter().toSql(["test_tag", "test_tag_2"]),
        createdDate: 1000,
        lastCheckedAt: 50000,
        longitude: null,
        latitude: null,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.entriesCache, oldEntriesCacheData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewEntriesCacheData,
          await newDb.select(newDb.entriesCache).get(),
        );
      },
    );
  });

  test('migration from v2 to v3 does not corrupt data', () async {
    final oldEntriesCacheData = <v2.EntriesCacheData>[
      v2.EntriesCacheData(
        tags: StringListConverter().toSql(["test_tag", "test_tag_2"]),
        createdDate: 1000,
        lastCheckedAt: 50000,
        longitude: 10.5,
        latitude: 5.2,
      ),
    ];
    final expectedNewEntriesCacheData = <v3.EntriesCacheData>[
      v3.EntriesCacheData(
        tags: StringListConverter().toSql(["test_tag", "test_tag_2"]),
        createdDate: 1000,
        lastCheckedAt: 50000,
        longitude: 10.5,
        latitude: 5.2,
        images: null
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) {
        batch.insertAll(oldDb.entriesCache, oldEntriesCacheData);
      },
      validateItems: (newDb) async {
        expect(
          expectedNewEntriesCacheData,
          await newDb.select(newDb.entriesCache).get(),
        );
      },
    );
  });
}

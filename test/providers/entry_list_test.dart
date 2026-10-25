import 'package:collection/collection.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:saf/saf.dart';
import 'package:journal/database.dart';
import 'package:journal/main.dart';
import 'package:journal/providers/entry_list.dart';
import 'entry_list_test.mocks.dart';

Uri folderUri = Uri.parse("content://abcdefghijklmnopqrstuvwxyz");

@GenerateMocks([], customMocks: [MockSpec<Saf>(as: #MockSafClient)])
void main() {
  test("test entryListProvider", () async {
    final safClient = MockSafClient();

    when(
      safClient.list(folderUri.toString())
    ).thenAnswer((_) async => []);

    final container = ProviderContainer.test(
      overrides: [
        appDatabaseProvider.overrideWithValue(AppDatabase.forTesting(NativeDatabase.memory())),
        folderUriProvider.overrideWithValue(folderUri),
        safProvider.overrideWithValue(safClient),
      ]
    );

    final entryListNotifier = container.read(entryListProvider.notifier);
    var entryList = await container.read(entryListProvider.future);
    expect(entryList, [], reason: "entryListProvider should be empty if no data could be loaded.");

    final dates = [
      DateTime(1970, 1, 1),
      DateTime(1970, 3, 2),
      DateTime(1970, 1, 5),
      DateTime(1970, 4, 1),
    ];
    
    for (var i = 0; i < dates.length; i++) {
      await entryListNotifier.addEntry(dates[i]);
    }

    entryList = await container.read(entryListProvider.future);
    expect(entryList, dates.sorted().reversed.toList(), reason: "Dates in entryListProvider should be sorted.");

    entryListNotifier.removeEntry(dates[0]);
    entryList = await container.read(entryListProvider.future);
    expect(entryList, isNot(contains(dates[0])));
  });
}

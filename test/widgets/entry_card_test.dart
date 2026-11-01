import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:journal/database.dart";
import "package:journal/main.dart";
import "package:journal/models/entry.dart";
import "package:journal/providers/entry.dart";
import "package:journal/widgets/entry_card.dart";
import "package:mockito/annotations.dart";

import "calendar_view_test.mocks.dart";

@GenerateMocks(
  [],
  customMocks: [MockSpec<AppDatabase>(as: #MockDatabaseClient)],
)
Future<void> _setupTests(WidgetTester tester) async {
  tester.view.physicalSize = Size(400, 800);
  final dbClient = MockDatabaseClient();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        folderUriProvider.overrideWithValue(Uri.parse("FOLDER_URI")),
        appDatabaseProvider.overrideWithValue(dbClient),
        entryProvider.overrideWithBuild(
          (_, _) => Entry(
            body: "BODY",
            location: null,
            images: [],
            tags: ["TAG1", "TAG2"],
            datetime: DateTime(2026, 1),
          ),
        ),
      ],
      child: MaterialApp(home: EntryCard(entryDt: DateTime(2026, 1))),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group("EntryCard", () {
    testWidgets("Contains body", (tester) async {
      await _setupTests(tester);
      expect(find.text("BODY", findRichText: true), findsOne);
    });

    testWidgets("Contains correct subtitle", (tester) async {
      await _setupTests(tester);
      expect(find.text("00:00 01 January - TAG1, TAG2"), findsOne);
    });
  });
}

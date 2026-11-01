import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:journal/main.dart";
import "package:journal/widgets/calendar_view.dart";
import "package:mockito/annotations.dart";
import "package:journal/database.dart";

import "calendar_view_test.mocks.dart";

@GenerateMocks(
  [],
  customMocks: [MockSpec<AppDatabase>(as: #MockDatabaseClient)],
)
Future<void> _setupTests(WidgetTester tester, GlobalKey monthSectionKey) async {
  final dbClient = MockDatabaseClient();
  tester.view.physicalSize = const Size(400, 800);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(dbClient)],
      child: MaterialApp(
        home: ListView(
          children: [
            MonthSectionWidget(
              key: monthSectionKey,
              month: DateTime(2026, 1),
              goToDate: (_) {},
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group("MonthSectionWidget", () {
    testWidgets("There is one instance of MonthSectionWidget", (tester) async {
      final monthSectionKey = GlobalKey();
      await _setupTests(tester, monthSectionKey);

      final finder = find.byKey(monthSectionKey);
      expect(
        finder,
        findsOneWidget,
        reason: "There should be exactly one instance of MonthSectionWidget",
      );
    });

    testWidgets("Calendar view displays correct amount of days.", (
      tester,
    ) async {
      final monthSectionKey = GlobalKey();
      await _setupTests(tester, monthSectionKey);

      final dayCellFinder = find.byType(DayCell);
      expect(
        dayCellFinder,
        findsExactly(31),
        reason: "There should be 31 instances of DayCell in January.",
      );
    });

    testWidgets("There is one widget with each day number.", (tester) async {
      final monthSectionKey = GlobalKey();
      await _setupTests(tester, monthSectionKey);

      for (int i = 1; i <= 31; i++) {
        final dayCellWithNumberFinder = find.widgetWithText(Center, "$i");
        expect(
          dayCellWithNumberFinder,
          findsOne,
          reason:
              "There should be one widget with each number, but could not find $i.",
        );
      }
    });
  });
}

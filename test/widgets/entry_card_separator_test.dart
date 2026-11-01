import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:intl/intl.dart";
import "package:journal/widgets/entry_card_seperator.dart";

Future<void> _setupTests(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(MaterialApp(home: child));
}

void main() {
  group("EntryCardSeparator", () {
    testWidgets("Does not display a month separator when month is the same", (
      tester,
    ) async {
      await _setupTests(
        tester,
        EntryCardSeperator(
          aboveEntryDt: DateTime(2026, 1, 14),
          belowEntryDt: DateTime(2026, 1, 15),
        ),
      );

      expect(find.byType(Text), findsNothing);
    });

    testWidgets("Displays a month separator when the month is not the same.", (
      tester,
    ) async {
      await _setupTests(
        tester,
        EntryCardSeperator(
          aboveEntryDt: DateTime(2026, 2, 14),
          belowEntryDt: DateTime(2026, 1, 27),
        ),
      );

      expect(
        find.widgetWithText(
          Padding,
          DateFormat.yMMMM().format(DateTime(2026, 1, 27)),
        ),
        findsOne,
      );
    });
  });
}

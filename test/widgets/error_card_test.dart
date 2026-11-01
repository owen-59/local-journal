import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:journal/widgets/error_card.dart";

const errorObject = {"Something": "Something"};

Future<void> _setupTests(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ErrorCard(error: errorObject, stackTrace: StackTrace.empty),
    ),
  );
}

void main() {
  group("ErrorCard", () {
    testWidgets("contains stringified error object", (tester) async {
      await _setupTests(tester);
      expect(find.widgetWithText(Column, errorObject.toString()), findsOne);
    });
  });
}

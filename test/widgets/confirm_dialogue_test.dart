import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:journal/widgets/confirm_dialogue.dart";

Future<void> _setupTests(
  WidgetTester tester, {
  bool isDestructive = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ).copyWith(onErrorContainer: Colors.red),
      ),
      home: ConfirmDialogue(
        titleText: "TITLE",
        description: "DESCRIPTION",
        cancelText: "CANCEL",
        confirmText: "CONFIRM",
        isDestructive: isDestructive,
      ),
    ),
  );
}

void main() {
  group("ConfirmDialogue", () {
    testWidgets("Title is shown once.", (tester) async {
      await _setupTests(tester);
      expect(find.text("TITLE"), findsOneWidget);
    });

    testWidgets("Description is shown once.", (tester) async {
      await _setupTests(tester);
      expect(find.text("DESCRIPTION"), findsOneWidget);
    });

    testWidgets("Cancel text is shown once.", (tester) async {
      await _setupTests(tester);
      expect(find.widgetWithText(TextButton, "CANCEL"), findsOneWidget);
    });

    testWidgets("Confirm text is shown once.", (tester) async {
      await _setupTests(tester);
      expect(find.widgetWithText(TextButton, "CONFIRM"), findsOneWidget);
    });

    testWidgets("Destructive button has onErrorContainer colour scheme.", (
      tester,
    ) async {
      await _setupTests(tester, isDestructive: true);
      expect(find.widgetWithText(TextButton, "CONFIRM"), findsOneWidget);

      final confirmButtonFinder = find.widgetWithText(TextButton, "CONFIRM");
      expect(confirmButtonFinder, findsOneWidget);

      final confirmButton = tester.widget<TextButton>(confirmButtonFinder);
      expect(confirmButton.style?.foregroundColor?.resolve({}), Colors.red);
    });
  });
}

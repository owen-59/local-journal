import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:journal/database.dart";
import "package:journal/main.dart";
import "package:journal/widgets/image_view.dart";
import "package:journal/widgets/images_list.dart";
import "package:mockito/annotations.dart";

import "calendar_view_test.mocks.dart";

@GenerateMocks(
  [],
  customMocks: [MockSpec<AppDatabase>(as: #MockDatabaseClient)],
)
void main() {
  group("ImagesList", () {
    testWidgets("Renders the correct amount of images.", (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            folderUriProvider.overrideWithValue(Uri.parse("")),
            appDatabaseProvider.overrideWithValue(MockDatabaseClient()),
          ],
          child: MaterialApp(
            home: ImagesList(
              entryDt: DateTime(2026),
              names: List.generate(3, (i) => "$i"),
              removeCallback: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ImageView), findsNWidgets(3));
    });
  });
}

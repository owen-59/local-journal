import "package:flutter_test/flutter_test.dart";
import "package:journal/utils/path.dart";

void main() {
  group("getTimeFromPath", () {
    test("returns null if input is malformed", () {
      final val = "abc";
      final res = getTimeFromPath(val);
      expect(res, null);
    });

    test("correctly extracts datetime", () {
      final val = "2026/01/10/1730.md";
      final res = getTimeFromPath(val);
      expect(res, DateTime(2026, 01, 10, 17, 30));
    });
  });

  group("getImagePath", () {
    test("returns correct path", () {
      final dt = DateTime(2026, 01, 10, 17, 30);
      final name = "image.jpg";
      final res = getImagePath(dt, name);
      expect(res, ["2026", "01", "10", name]);
    });
  });
}

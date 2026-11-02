import "package:flutter_test/flutter_test.dart";
import "package:journal/utils/months.dart";

void main() {
  group("getWeeksInMonth", () {
    test("returns correct amount", () {
      final val = DateTime(2026, 1);
      final res = getWeeksInMonth(val);
      expect(res, 5);
    });
  });
}

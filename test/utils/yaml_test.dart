import "package:flutter_test/flutter_test.dart";
import "package:journal/utils/yaml.dart";
import "package:yaml/yaml.dart";

void main() {
  group("Test yaml:", () {
    group("dynamicYamlToList", () {
      test("returns empty list if the passed object is not a YamlList", () {
        final val = 8;
        final res = dynamicYamlToList(val);
        expect(res, []);
      });

      test("non R elements are removed", () {
        final val = YamlList.wrap(["test1", "test2", 3, "test4"]);
        final res = dynamicYamlToList<String>(val);

        expect(res, ["test1", "test2", "test4"]);
      });
    });

    group("locationFromYaml", () {
      test("returns null if coordinates are null", () {
        final val = YamlMap.wrap({});
        final res = locationFromYaml(val);
        expect(res, null);
      });

      for (final key in ["location", "place_name", "address"]) {
        test("returns null if $key is neither String nor null", () {
          final val = YamlMap.wrap({
            "coordinates": [1, 2],
            key: 5,
          });
          final res = locationFromYaml(val);
          expect(res, null);
        });
      }
    });
  });
}

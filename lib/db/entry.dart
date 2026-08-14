import 'package:journal/db/file_utils.dart';
import 'package:journal/logger.dart';
import 'package:journal/main.dart';
import 'package:journal/types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "entry.g.dart";

@riverpod
class EntryNotifier extends _$EntryNotifier {
  Future<DateTime> getDatetime() async {
    final datetime = DateTime.tryParse(datetimeString);
    if (datetime == null) {
      logger.w("Tried to load an entry with an invalid datetime.");
      throw Exception("Not a valid entry identifier.");
    }
    return datetime;
  }

  @override
  Future<Entry> build(String datetimeString) async {
    logger.i("Loading entry $datetimeString");
    final rootFolder = ref.watch(folderUriProvider);
    final datetime = await getDatetime();

    final path = pathFromDatetime(datetime);
    final content = await readFile(rootFolder.toString(), path);

    if (content == null) {
      logger.w("Couldn't load the requested entry.");
      throw Exception("Couldn't find the entry.");
    }

    final entry = await Entry.read(datetimeString, rootFolder.toString());
    if (entry != null) return entry;

    throw Exception("Entry not found.");
  }

  Future<void> updateEntry(String newBody) async {
    final entry = state.asData?.value;
    if (entry == null) {
      logger.w("Tried to update entry when the entry provider was busy.");
      return;
    }

    final rootFolder = ref.watch(folderUriProvider);

    await entry.write(rootFolder.toString());
  }
}

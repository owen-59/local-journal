import 'package:journal/entry.dart';
import 'package:journal/logger.dart';
import 'package:journal/main.dart';
import 'package:journal/utils/file.dart';
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

  Future<Entry> writeWith({
    String? body,
    DateTime? datetime,
    List<String>? tags,
  }) async {
    final current = state.asData?.value;
    final rootFolder = ref.watch(folderUriProvider).toString();
    if (current == null) {
      logger.w("Tried to update entry when the entry provider was busy.");
      throw Exception("Tried to update entry when the provider was busy.");
    }

    final newEntry = current.copyWith(
      body: body,
      datetime: datetime,
      tags: tags,
    );

    if (newEntry.datetime != current.datetime) {
      await current.delete(rootFolder);
    }
    await newEntry.write(rootFolder);
    return newEntry;
  }
}

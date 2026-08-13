import 'package:journal/db/write_file.dart';
import 'package:journal/main.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part "create.g.dart";

@riverpod
class CreateController extends _$CreateController {
  @override
  FutureOr<void> build() => null;

  Future<String> createEntry() async {
    final rootFolder = ref.watch(folderUriProvider);
    final newDatetime = DateTime.now();
    final path = pathFromDatetime(newDatetime);
    await writeFile(rootFolder.toString(),path,"");

    return "/entry/$newDatetime";
  }
}

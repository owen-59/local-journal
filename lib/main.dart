import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journal/db.dart';
import 'package:journal/widgets/entry_editor.dart';
import 'package:journal/widgets/folder_selection_page.dart';
import 'package:journal/widgets/home_screen.dart';
import 'package:saf/saf.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

// initialise this in overrides
final databaseProvider = Provider<Database>((ref) {
  throw UnimplementedError();
});

final _router = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: "/entry/:datetime",
      builder: (context, state) =>
          EntryEditor(entryDateString: state.pathParameters["datetime"]!),
    ),
  ],
);

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late Saf _saf;
  late Database _database;
  bool _authorised = false;

  @override
  initState() {
    super.initState();
    _saf = Saf();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSaf());
  }

  Future<void> _initSaf() async {
    final grants = await _saf.persistedPermissions();
    if (grants.isNotEmpty) {
      onPermissionsGranted(Uri.parse(grants[0].uri));
    }
  }

  void onPermissionsGranted(Uri dirUri) {
    setState(() {
      _authorised = true;
      _database = Database(folderUri: dirUri, saf: _saf);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _authorised
        ? ProviderScope(
            overrides: [databaseProvider.overrideWithValue(_database)],
            retry: (_, _) => null,
            child: MaterialApp.router(routerConfig: _router),
          )
        : FolderSelectionPage(saf: _saf, onGranted: onPermissionsGranted);
  }
}

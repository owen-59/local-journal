import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journal/logger.dart';
import 'package:journal/widgets/entry_editor.dart';
import 'package:journal/widgets/folder_selection_page.dart';
import 'package:journal/widgets/home_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saf/saf.dart';

part "main.g.dart";

void main() async {
  logger.d("Starting main()");
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

// initialise this in overrides
@riverpod
Uri folderUri(Ref ref) {
  logger.d("Accessed folderUriProvider before overriding!");
  throw UnimplementedError();
}

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
  late Uri _folderUri;
  bool _authorised = false;

  @override
  initState() {
    super.initState();
    _saf = Saf();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSaf());
  }

  Future<void> _initSaf() async {
    logger.d("Initialising Saf");
    final grants = await _saf.persistedPermissions();
    if (grants.isNotEmpty) {
      onPermissionsGranted(Uri.parse(grants[0].uri));
    }
  }

  void onPermissionsGranted(Uri dirUri) {
    logger.d("Permissions granted to $dirUri");
    setState(() {
      _authorised = true;
      _folderUri = dirUri;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _authorised
        ? ProviderScope(
            overrides: [folderUriProvider.overrideWithValue(_folderUri)],
            retry: (_, _) => null,
            child: DynamicColorBuilder(
              builder: (light, dark) => MaterialApp.router(
                routerConfig: _router,
                theme: ThemeData(
                  colorScheme: light ?? ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                ),
                darkTheme: ThemeData(
                  colorScheme: dark ?? ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark)
                ),
              ),
            )
          )
        : FolderSelectionPage(saf: _saf, onGranted: onPermissionsGranted);
  }
}

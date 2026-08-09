import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journal/widgets/folder_selection_page.dart';
import 'package:journal/widgets/home_screen.dart';
import 'package:saf/saf.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

final folderUriProvider = Provider<String>((ref) => "");

final _router = GoRouter(
  routes: [GoRoute(path: "/", builder: (context, state) => HomeScreen())],
);

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late Saf _saf;
  String _folder = "";
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
      onPermissionsGranted(grants[0].uri);
    }
  }

  void onPermissionsGranted(String dir) {
    setState(() {
      _authorised = true;
      _folder = dir;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _authorised
        ? ProviderScope(
            overrides: [folderUriProvider.overrideWithValue(_folder)],
            child: MaterialApp.router(routerConfig: _router),
          )
        : FolderSelectionPage(saf: _saf, onGranted: onPermissionsGranted);
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:journal/widgets/home_screen.dart';

void main() {
    runApp(const App());
}

final _router = GoRouter(
    routes: [
        GoRoute(
            path: "/",
            builder: (context, state) => HomeScreen(),
        )
    ]
);

class App extends StatelessWidget {
    const App({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp.router(
            routerConfig: _router,
        );
    }
}


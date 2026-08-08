import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
    runApp(const App());
}

final _router = GoRouter(
    routes: [
        GoRoute(
            path: "/",
            builder: (context, state) => Scaffold(
                appBar: AppBar(title: Text("Home Screen")),
                body: Center(
                    child: Text("Home"),
                )
            )
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


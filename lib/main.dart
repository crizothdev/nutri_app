import 'package:flutter/material.dart';
import 'package:nutri_app/bindings.dart';
import 'package:nutri_app/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    @override
    void dispose() {
      AppBindings.I
          .disposeAll(); // limpa tudo (ex.: ao fechar app ou no fluxo de logout)
      super.dispose();
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: routes,
    );
  }
}

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
      title: 'Nutrify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff48712d)),
        useMaterial3: true,
      ),
      routes: routes,
    );
  }
}

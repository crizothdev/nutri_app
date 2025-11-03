import 'package:flutter/material.dart';
import 'package:nutri_app/app_initializer.dart';
import 'package:nutri_app/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();
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

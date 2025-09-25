import 'package:flutter/material.dart';
import 'package:nutri_app/bindings.dart';
import 'package:nutri_app/modules/home/home_controller.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = AppBindings.I.get<HomeController>(() => HomeController());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<HomeController>(
      state: controller,
      builder: (context, state) {
        return Container();
      },
    );
  }
}

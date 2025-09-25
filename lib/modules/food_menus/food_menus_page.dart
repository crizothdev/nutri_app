import 'package:flutter/material.dart';
import 'package:nutri_app/bindings.dart';
import 'package:nutri_app/modules/food_menus/food_menus_controller.dart';
import 'package:nutri_app/widgets/statefull_wrapper.dart';

class FoodMenusPage extends StatefulWidget {
  const FoodMenusPage({super.key});

  @override
  State<FoodMenusPage> createState() => _FoodMenusPageState();
}

class _FoodMenusPageState extends State<FoodMenusPage> {
  final controller =
      AppBindings.I.get<FoodMenusController>(() => FoodMenusController());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotifierScaffold<FoodMenusController>(
      state: controller,
      isLoading: controller.isLoading,
      builder: (context, state) {
        return Container();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nutri_app/modules/food_menus_details/food_menus_details_controller.dart';
import 'package:nutri_app/widgets/food_menus_details_widgets.dart';

class MenuDetailPage extends StatefulWidget {
  final int menuId;
  const MenuDetailPage({super.key, required this.menuId});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  late final MenuDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = MenuDetailController(widget.menuId);
    controller.addListener(() => setState(() {}));
    controller.loadData();
  }

  @override
  void dispose() {
    controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2E9), // fundo verde clarinho
      appBar: AppBar(
        backgroundColor: const Color(0xFFBFCDB3), // verde suave
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Refeições',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.meals.isEmpty
              ? const Center(child: Text('Nenhuma refeição encontrada'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: controller.meals
                        .map((meal) => MealCard(
                              meal: meal,
                              foods: controller.mealFoods[meal.id!] ?? [],
                            ))
                        .toList(),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Aqui acredito que seria a parte de adicionar, tenho que ver com o time se ja tem feito isto 
        },
        backgroundColor: const Color(0xFF4C7C3D),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}

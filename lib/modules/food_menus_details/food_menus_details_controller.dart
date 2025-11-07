import 'package:flutter/material.dart';
import 'package:nutri_app/core/models/meal.dart';
import 'package:nutri_app/core/models/meal_food.dart';


class MenuDetailController extends ChangeNotifier {
  final int menuId;

  MenuDetailController(this.menuId);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Meal> _meals = [];
  List<Meal> get meals => _meals;

  Map<int, List<MealFood>> _mealFoods = {};
  Map<int, List<MealFood>> get mealFoods => _mealFoods;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    // Mocks
    _meals = [
      Meal(id: 1, menuId: menuId, name: 'Café da manhã', orderIndex: 0),
      Meal(id: 2, menuId: menuId, name: 'Almoço', orderIndex: 1),
      Meal(id: 3, menuId: menuId, name: 'Jantar', orderIndex: 2),
    ];

    _mealFoods = {
      1: [
        MealFood(mealId: 1, foodId: 1, quantity: 1, kcalTotal: 80, notes: 'Banana'),
        MealFood(mealId: 1, foodId: 2, quantity: 2, kcalTotal: 150, notes: 'Aveia'),
      ],
      2: [
        MealFood(mealId: 2, foodId: 3, quantity: 1, kcalTotal: 200, notes: 'Arroz'),
        MealFood(mealId: 2, foodId: 4, quantity: 1, kcalTotal: 150, notes: 'Feijão'),
        MealFood(mealId: 2, foodId: 5, quantity: 1, kcalTotal: 250, notes: 'Frango'),
      ],
      3: [
        MealFood(mealId: 3, foodId: 6, quantity: 1, kcalTotal: 180, notes: 'Salada'),
        MealFood(mealId: 3, foodId: 7, quantity: 1, kcalTotal: 300, notes: 'Peixe'),
      ],
    };

    _isLoading = false;
    notifyListeners();
  }
}


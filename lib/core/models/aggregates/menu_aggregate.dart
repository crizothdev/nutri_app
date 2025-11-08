import '../menu.dart';

class MealFoodView {
  final int foodId;
  final String name;
  final String defaultPortion;
  final double kcalPerPortion;
  final double quantity;
  final double kcalTotal;
  final String? notes;

  const MealFoodView({
    required this.foodId,
    required this.name,
    required this.defaultPortion,
    required this.kcalPerPortion,
    required this.quantity,
    required this.kcalTotal,
    this.notes,
  });

  factory MealFoodView.fromJoinMap(Map<String, dynamic> m) => MealFoodView(
        foodId: m['food_id'] as int,
        name: m['name'] as String,
        defaultPortion: m['default_portion'] as String,
        kcalPerPortion: (m['kcal_per_portion'] as num).toDouble(),
        quantity: (m['quantity'] as num).toDouble(),
        kcalTotal: (m['kcal_total'] as num).toDouble(),
        notes: m['notes'] as String?,
      );
}

class MealAggregate {
  final Meal meal;
  final List<MealFoodView> foods;

  const MealAggregate({required this.meal, required this.foods});

  double get totalKcal => foods.fold(0.0, (acc, it) => acc + (it.kcalTotal));
}

class MenuAggregate {
  final Menu menu;
  final List<MealAggregate> meals;
  final List<Map<String, dynamic>> clients; // {id, name}

  const MenuAggregate(
      {required this.menu, required this.meals, required this.clients});

  double get totalKcal => meals.fold(0.0, (acc, m) => acc + m.totalKcal);
}

import 'food.dart';

class Menu {
  final int? id;
  final String title;
  final int? targetKcal;

  /// Meals embutidas no Menu (não persistidas em tabela própria)
  final List<Meal> meals;

  const Menu({
    this.id,
    required this.title,
    this.targetKcal,
    this.meals = const [],
  });

  Menu copyWith({
    int? id,
    String? title,
    int? targetKcal,
    List<Meal>? meals,
  }) =>
      Menu(
        id: id ?? this.id,
        title: title ?? this.title,
        targetKcal: targetKcal ?? this.targetKcal,
        meals: meals ?? this.meals,
      );

  /// Map “flat” (apenas campos do DB)
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'target_kcal': targetKcal,
      };

  factory Menu.fromMap(Map<String, dynamic> m, {List<Meal> meals = const []}) =>
      Menu(
        id: m['id'] as int?,
        title: m['title'] as String,
        targetKcal: m['target_kcal'] as int?,
        meals: meals,
      );

  /// Soma total de calorias de todas as meals
  double get totalCalories =>
      meals.fold<double>(0.0, (sum, meal) => sum + meal.totalCalories);
}

class Meal {
  final String title;
  final String? description;
  final List<MealFood> foods;

  const Meal({
    required this.title,
    this.description,
    this.foods = const [],
  });

  Meal copyWith({
    String? title,
    String? description,
    List<MealFood>? foods,
  }) =>
      Meal(
        title: title ?? this.title,
        description: description ?? this.description,
        foods: foods ?? this.foods,
      );

  /// Total de calorias desta refeição (∑ food.calories * quantity)
  double get totalCalories =>
      foods.fold<double>(0.0, (sum, f) => sum + f.totalCalories);
}

class MealFood {
  /// Food da base (contém `calories` por porção padrão)
  final Food food;

  /// Multiplicador de porções (ex.: 1.5 porções)
  final double quantity;

  final String? notes;

  const MealFood({
    required this.food,
    this.quantity = 1.0,
    this.notes,
  });

  MealFood copyWith({
    Food? food,
    double? quantity,
    String? notes,
  }) =>
      MealFood(
        food: food ?? this.food,
        quantity: quantity ?? this.quantity,
        notes: notes ?? this.notes,
      );

  /// Calorias totais deste item na meal
  double get totalCalories => food.calories * quantity;
}

class MealFoodInput {
  final int foodId;
  final double quantity;
  final String? notes;

  const MealFoodInput(
      {required this.foodId, required this.quantity, this.notes});
}

class MealInput {
  final String name;
  final int orderIndex;
  final List<MealFoodInput> foods;

  const MealInput({
    required this.name,
    required this.orderIndex,
    required this.foods,
  });
}

class MenuAggregateInput {
  final String title;
  final int? targetKcal;
  final List<int> clientIds;
  final List<MealInput> meals;

  const MenuAggregateInput({
    required this.title,
    this.targetKcal,
    required this.clientIds,
    required this.meals,
  });

  /// Converte para a estrutura esperada pelo MenusDatasource.createMenuWithMeals
  List<Map<String, dynamic>> toMealsMap() => meals
      .map((m) => {
            'name': m.name,
            'orderIndex': m.orderIndex,
            'foods': m.foods
                .map((f) => {
                      'foodId': f.foodId,
                      'quantity': f.quantity,
                      'notes': f.notes,
                    })
                .toList(),
          })
      .toList();
}

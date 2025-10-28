class MealFood {
  final int mealId;
  final int foodId;
  final double quantity;
  final double kcalTotal;
  final String? notes;

  const MealFood({
    required this.mealId,
    required this.foodId,
    required this.quantity,
    required this.kcalTotal,
    this.notes,
  });

  MealFood copyWith({
    int? mealId,
    int? foodId,
    double? quantity,
    double? kcalTotal,
    String? notes,
  }) =>
      MealFood(
        mealId: mealId ?? this.mealId,
        foodId: foodId ?? this.foodId,
        quantity: quantity ?? this.quantity,
        kcalTotal: kcalTotal ?? this.kcalTotal,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toMap() => {
        'meal_id': mealId,
        'food_id': foodId,
        'quantity': quantity,
        'kcal_total': kcalTotal,
        'notes': notes,
      };

  factory MealFood.fromMap(Map<String, dynamic> m) => MealFood(
        mealId: m['meal_id'] as int,
        foodId: m['food_id'] as int,
        quantity: (m['quantity'] as num).toDouble(),
        kcalTotal: (m['kcal_total'] as num).toDouble(),
        notes: m['notes'] as String?,
      );
}

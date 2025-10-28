import '../models/meal.dart';

abstract class MealsRepository {
  Future<int> add(Meal meal);
  Future<void> attachFood(
      {required int mealId,
      required int foodId,
      required double quantity,
      String? notes});
  Future<void> removeFood({required int mealId, required int foodId});
  Future<void> reorder(int mealId, int newIndex);
  Future<void> rename(int mealId, String newName);
  Future<void> delete(int mealId);
}

import '../../models/meal.dart';
import '../../services/database_service.dart';
import '../../datasources/meals_datasource.dart';
import '../meals_repository.dart';

class MealsRepositoryImpl implements MealsRepository {
  final LocalDatabaseService db;
  late final MealsDatasource _ds;

  MealsRepositoryImpl(this.db) {
    _ds = MealsDatasource(db);
  }

  @override
  Future<int> add(Meal meal) async {
    return await _ds.addMeal(
        menuId: meal.menuId, name: meal.name, orderIndex: meal.orderIndex);
  }

  @override
  Future<void> attachFood(
      {required int mealId,
      required int foodId,
      required double quantity,
      String? notes}) async {
    await _ds.attachFoodToMeal(
        mealId: mealId, foodId: foodId, quantity: quantity, notes: notes);
  }

  @override
  Future<void> removeFood({required int mealId, required int foodId}) async {
    await _ds.removeFoodFromMeal(mealId, foodId);
  }

  @override
  Future<void> reorder(int mealId, int newIndex) async {
    await _ds.reorderMeal(mealId, newIndex);
  }

  @override
  Future<void> rename(int mealId, String newName) async {
    await _ds.renameMeal(mealId, newName);
  }

  @override
  Future<void> delete(int mealId) async {
    await _ds.deleteMeal(mealId);
  }
}

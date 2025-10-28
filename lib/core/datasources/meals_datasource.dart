import 'package:nutri_app/core/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class MealsDatasource {
  final LocalDatabaseService _db;
  final mealsTable = TableNames.meals;
  final foodsTable = TableNames.foods;
  final mealFoodsTable = TableNames.meal_foods;

  MealsDatasource(this._db);

  Future<int> addMeal({
    required int menuId,
    required String name,
    int orderIndex = 0,
  }) async {
    return await _db.insertData(mealsTable, {
      'menu_id': menuId,
      'name': name,
      'order_index': orderIndex,
    });
  }

  Future<int> attachFoodToMeal({
    required int mealId,
    required int foodId,
    required double quantity,
    String? notes,
  }) async {
    // buscar kcal_per_portion do alimento
    final food = await _db.getData(
      foodsTable,
      where: 'id = ?',
      whereArgs: [foodId],
      limit: 1,
    );
    if (food.isEmpty) throw Exception('Alimento não encontrado');

    final kcalPerPortion = (food.first['kcal_per_portion'] as num).toDouble();
    final kcalTotal = kcalPerPortion * quantity;

    return await _db.insertData(
      mealFoodsTable,
      {
        'meal_id': mealId,
        'food_id': foodId,
        'quantity': quantity,
        'kcal_total': kcalTotal,
        'notes': notes ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeFoodFromMeal(int mealId, int foodId) async {
    return await _db.deleteWhere(
      mealFoodsTable,
      where: 'meal_id = ? AND food_id = ?',
      whereArgs: [mealId, foodId],
    );
  }

  Future<int> reorderMeal(int mealId, int newIndex) async {
    return await _db.updateById(
      mealsTable,
      {'order_index': newIndex},
      id: mealId,
    );
  }

  Future<int> renameMeal(int mealId, String newName) async {
    return await _db.updateById(
      mealsTable,
      {'name': newName},
      id: mealId,
    );
  }

  Future<int> deleteMeal(int mealId) async {
    // meal_foods é removido por ON DELETE CASCADE
    return await _db.deleteData(mealsTable, mealId);
  }
}

import '../models/food.dart';

abstract class FoodsRepository {
  Future<int> upsert(Food food);
  Future<void> importFromAppJson(List<Map<String, dynamic>> appJson);
  Future<List<Food>> searchByName(String term, {int limit});
  Future<Food?> byId(int id);
  Future<void> delete(int id);
}

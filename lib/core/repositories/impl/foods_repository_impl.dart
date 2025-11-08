import '../../models/food.dart';
import '../../services/database_service.dart';
import '../../datasources/foods_datasource.dart';
import '../foods_repository.dart';

class FoodsRepositoryImpl implements FoodsRepository {
  final LocalDatabaseService db;
  late final FoodsDatasource _ds;

  FoodsRepositoryImpl(this.db) {
    _ds = FoodsDatasource(db);
  }

  @override
  Future<int> upsert(Food food) async {
    return await _ds.upsertFood(
      code: food.code,
      name: food.name,
      defaultPortion: food.defaultPortion,
      calories: food.calories,
    );
  }

  @override
  Future<void> importFromAppJson(List<Map<String, dynamic>> appJson) async {
    // Converte JSON do app para o formato do datasource
    final toImport =
        appJson.map((j) => Food.fromAppJson(j)).map((f) => f.toMap()).toList();
    // FoodsDatasource.importFoodsFromJson espera chaves: code, name, default_portion, calories
    await _ds.importFoodsFromJson(toImport);
  }

  @override
  Future<List<Food>> searchByName(String term, {int limit = 30}) async {
    final rows = await _ds.searchFoodsByName(term, limit: limit);
    return rows.map(Food.fromMap).toList();
  }

  @override
  Future<Food?> byId(int id) async {
    final r = await _ds.getFoodById(id);
    return r == null ? null : Food.fromMap(r);
  }

  @override
  Future<void> delete(int id) async {
    await _ds.deleteFood(id);
  }
}

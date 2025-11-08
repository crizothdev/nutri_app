import 'package:nutri_app/core/repositories/menus_repository.dart';

import '../../models/menu.dart';
import '../../models/aggregates/menu_aggregate.dart';
import '../../models/aggregates/menu_aggregate_input.dart';
import '../../services/database_service.dart';
import '../../datasources/menus_datasource.dart';
import '../../datasources/foods_datasource.dart';

class MenusRepositoryImpl implements MenusRepository {
  final LocalDatabaseService db;
  late final MenusDatasource _ds;
  late final FoodsDatasource _foodsDs;

  MenusRepositoryImpl(this.db) {
    _ds = MenusDatasource(db);
    _foodsDs = FoodsDatasource(db);
  }

  @override
  Future<int> createAggregate(MenuAggregateInput input) async {
    // Agora meals são embutidas (title, description?, foods[])
    return _ds.createMenuWithMeals(
      title: input.title,
      targetKcal: input.targetKcal,
      clientIds: input.clientIds,
      meals: input.toMealsMap(), // novo formato embutido
    );
  }

  @override
  Future<void> linkToClients(int menuId, List<int> clientIds) async {
    await _ds.linkMenuToClients(menuId, clientIds);
  }

  @override
  Future<int> duplicateForClients(
    int sourceMenuId,
    List<int> targetClientIds, {
    String? newTitle,
  }) async {
    return _ds.duplicateMenuForClients(
      sourceMenuId,
      targetClientIds,
      newTitle: newTitle,
    );
  }

  @override
  Future<List<Menu>> byClient(int clientId) async {
    // Consulta expandida; aqui retornamos apenas o Menu “flat” para listagem
    final rows =
        await _ds.getMenusByClientWithMealsAndFoods(clientId, _foodsDs);

    return rows
        .map(
          (m) => Menu(
            id: m['menu_id'] as int?,
            title: m['title'] as String,
            targetKcal: m['target_kcal'] as int?,
          ),
        )
        .toList();
  }

  @override
  Future<MenuAggregate?> aggregate(int menuId) async {
    // Detalhe com meals e foods expandidos
    final d = await _ds.getMenuDetail(menuId, _foodsDs);
    if (d == null) return null;

    final menu = Menu(
      id: d['id'] as int?,
      title: d['title'] as String,
      targetKcal: d['target_kcal'] as int?,
    );

    final clients = (d['clients'] as List).cast<Map<String, dynamic>>();

    final meals = <MealAggregate>[];
    final mealsList = (d['meals'] as List? ?? const <Map<String, dynamic>>[])
        .cast<Map<String, dynamic>>();

    for (var i = 0; i < mealsList.length; i++) {
      final m = mealsList[i];

      // Sem tabela própria de meals
      final meal = Meal(
        title: (m['title'] ?? m['name'] ?? '').toString(),
        description: m['description']?.toString(),
        foods: const [], // foods do modelo não são usados no agregado (usamos MealFoodView)
      );

      // Foods já vêm como rows; convertemos para MealFoodView
      final foods = (m['foods'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(_rowToMealFoodView)
          .toList();

      meals.add(MealAggregate(meal: meal, foods: foods));
    }

    return MenuAggregate(menu: menu, meals: meals, clients: clients);
  }

  /// Converte uma row de `foods` em MealFoodView.
  /// Compatível com o novo schema: usa `calories` (kcal/porção), não há mais `kcal_per_portion`.
  /// Campos não existentes (quantity/kcal_total/notes) ficam nulos.
  MealFoodView _rowToMealFoodView(Map<String, dynamic> r) {
    return MealFoodView.fromJoinMap({
      'food_id': r['id'],
      'name': r['name'],
      'default_portion': r['default_portion'],
      'calories': r['calories'],
      'quantity': null,
      'kcal_total': null,
      'notes': null,
    });
  }
}

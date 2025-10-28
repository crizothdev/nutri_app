import '../../models/menu.dart';
import '../../models/meal.dart';
import '../../models/aggregates/menu_aggregate.dart';
import '../../models/aggregates/menu_aggregate_input.dart';
import '../../services/database_service.dart';
import '../../datasources/menus_datasource.dart';
import '../menus_repository.dart';

class MenusRepositoryImpl implements MenusRepository {
  final LocalDatabaseService db;
  late final MenusDatasource _ds;

  MenusRepositoryImpl(this.db) {
    _ds = MenusDatasource(db);
  }

  @override
  Future<int> createAggregate(MenuAggregateInput input) async {
    return await _ds.createMenuWithMeals(
      title: input.title,
      targetKcal: input.targetKcal,
      clientIds: input.clientIds,
      meals: input.toMealsMap(),
    );
  }

  @override
  Future<void> linkToClients(int menuId, List<int> clientIds) async {
    await _ds.linkMenuToClients(menuId, clientIds);
  }

  @override
  Future<int> duplicateForClients(int sourceMenuId, List<int> targetClientIds,
      {String? newTitle}) async {
    return await _ds.duplicateMenuForClients(sourceMenuId, targetClientIds,
        newTitle: newTitle);
  }

  @override
  Future<List<Menu>> byClient(int clientId) async {
    final rows = await _ds.getMenusByClientWithMealsAndFoods(clientId);
    // Aqui retornamos apenas os Menus (sem meals) para listagem rápida
    return rows
        .map((m) => Menu(
              id: m['menu_id'] as int?,
              title: m['title'] as String,
              targetKcal: m['target_kcal'] as int?,
            ))
        .toList();
  }

  @override
  Future<MenuAggregate?> aggregate(int menuId) async {
    final d = await _ds.getMenuDetail(menuId);
    if (d == null) return null;

    final menu = Menu(
      id: d['id'] as int?,
      title: d['title'] as String,
      targetKcal: d['target_kcal'] as int?,
    );

    final clients = (d['clients'] as List).cast<Map<String, dynamic>>();

    final meals = <MealAggregate>[];
    for (final m in (d['meals'] as List)) {
      final meal = Meal(
        id: m['id'] as int?,
        menuId: menu.id!,
        name: m['name'] as String,
        orderIndex: (m['orderIndex'] as num).toInt(),
      );

      final foods = (m['foods'] as List)
          .map<Map<String, dynamic>>((x) => x as Map<String, dynamic>)
          .map(MealFoodView.fromJoinMap)
          .toList();

      meals.add(MealAggregate(meal: meal, foods: foods));
    }

    return MenuAggregate(menu: menu, meals: meals, clients: clients);
  }
}

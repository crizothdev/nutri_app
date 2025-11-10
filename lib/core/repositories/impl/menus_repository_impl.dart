import 'package:nutri_app/core/models/food.dart';
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

  Future<void> update(Menu menu) async {
    if (menu.id == null) {
      throw ArgumentError('Menu sem id para update.');
    }

    final mealsJsonList = _serializeMeals(menu.meals);
    await _ds.updateMenu(
      id: menu.id!,
      title: menu.title,
      targetKcal: menu.targetKcal,
      mealsJsonList: mealsJsonList,
    );
  }

  List<Map<String, dynamic>> _serializeMeals(List<Meal> meals) {
    return meals.map((m) {
      final foodIds = m.foods
          .map((mf) => mf.food.id)
          .whereType<int>() // garante só ids válidos
          .toList();

      return {
        'title': m.title,
        if (m.description != null) 'description': m.description,
        'foodIds': foodIds,
      };
    }).toList();
  }

  @override
  Future<List<Menu>> byClient(int clientId) async {
    final rows =
        await _ds.getMenusByClientWithMealsAndFoods(clientId, _foodsDs);

    return rows.map<Menu>((m) {
      final mealsList =
          (m['meals'] as List? ?? const []).cast<Map<String, dynamic>>();

      final meals = mealsList.map<Meal>((mm) {
        // Lista de "foods" já expandida pelo datasource
        final foodsRows =
            (mm['foods'] as List? ?? const []).cast<Map<String, dynamic>>();

        final items = foodsRows.map<MealFood>((fr) {
          // Constrói o Food a partir da row do banco
          final food = Food.fromMap(fr);

          // Se o datasource passar quantity/notes, usamos; senão: defaults
          final quantity = (fr['quantity'] is num)
              ? (fr['quantity'] as num).toDouble()
              : 1.0;
          final notes = fr['notes']?.toString();

          return MealFood(food: food, quantity: quantity, notes: notes);
        }).toList();

        return Meal(
          title: (mm['title'] ?? mm['name'] ?? '').toString(),
          description: mm['description']?.toString(),
          foods: items,
        );
      }).toList();

      return Menu(
        id: m['menu_id'] as int?,
        title: (m['title'] ?? '').toString(),
        targetKcal: m['target_kcal'] as int?,
        meals: meals,
      );
    }).toList();
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

  @override
  Future<int> deleteMenuForClient(int menuId, int clientId) {
    return _ds.deleteMenuForClient(menuId, clientId);
  }

  @override
  Future<int> create({
    required String title,
    int? targetKcal,
    required int clientId,
  }) async {
    // cria o menu “vazio” já vinculado ao cliente
    final newMenuId = await _ds.createMenuWithMeals(
      title: title,
      targetKcal: targetKcal,
      clientIds: [clientId],
      meals: const [], // sem meals no create
    );
    return newMenuId;
  }
}

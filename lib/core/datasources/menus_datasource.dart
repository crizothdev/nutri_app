import 'package:nutri_app/core/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class MenusDatasource {
  final LocalDatabaseService _db;

  final menusTable = TableNames.menus;
  final clientMenusTable = TableNames.client_menus;
  final mealsTable = TableNames.meals;
  final foodsTable = TableNames.foods;
  final mealFoodsTable = TableNames.meal_foods;

  MenusDatasource(this._db);

  /// Cria um menu e associa a N clientes; também cria refeições e insere foods.
  /// Estrutura:
  /// title, targetKcal, clientIds, meals: [{name, orderIndex, foods:[{foodId, quantity, notes}]}]
  Future<int> createMenuWithMeals({
    required String title,
    int? targetKcal,
    required List<int> clientIds,
    required List<Map<String, dynamic>> meals,
  }) async {
    return await _db.database.transaction<int>((txn) async {
      final menuId = await txn.insert(menusTable.name, {
        'title': title,
        'target_kcal': targetKcal,
      });

      // vincular clientes
      final linkBatch = txn.batch();
      for (final cId in clientIds) {
        linkBatch.insert(
          clientMenusTable.name,
          {'client_id': cId, 'menu_id': menuId},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await linkBatch.commit(noResult: true);

      // criar meals + meal_foods
      for (final m in meals) {
        final mealId = await txn.insert(mealsTable.name, {
          'menu_id': menuId,
          'name': m['name'],
          'order_index': m['orderIndex'] ?? 0,
        });

        final foods = (m['foods'] as List?) ?? const [];
        final batchFoods = txn.batch();
        for (final f in foods) {
          final int foodId = f['foodId'] as int;
          final double quantity = (f['quantity'] as num).toDouble();

          final foodRow = await txn.query(
            foodsTable.name,
            where: 'id = ?',
            whereArgs: [foodId],
            limit: 1,
          );
          if (foodRow.isEmpty) continue;

          final kcalPerPortion =
              (foodRow.first['kcal_per_portion'] as num).toDouble();
          final kcalTotal = kcalPerPortion * quantity;

          batchFoods.insert(
            mealFoodsTable.name,
            {
              'meal_id': mealId,
              'food_id': foodId,
              'quantity': quantity,
              'kcal_total': kcalTotal,
              'notes': f['notes'] ?? '',
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batchFoods.commit(noResult: true);
      }

      return menuId;
    });
  }

  /// Associa um menu existente a novos clientes (N:N)
  Future<void> linkMenuToClients(int menuId, List<int> clientIds) async {
    final batch = _db.database.batch();
    for (final cId in clientIds) {
      batch.insert(
        clientMenusTable.name,
        {'client_id': cId, 'menu_id': menuId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Duplica um menu (estrutura completa) para outros clientes
  Future<int> duplicateMenuForClients(
    int sourceMenuId,
    List<int> targetClientIds, {
    String? newTitle,
  }) async {
    return await _db.database.transaction<int>((txn) async {
      final menuRow = (await txn.query(
        menusTable.name,
        where: 'id = ?',
        whereArgs: [sourceMenuId],
        limit: 1,
      ))
          .first;

      final newMenuId = await txn.insert(menusTable.name, {
        'title': newTitle ?? '${menuRow['title']} (cópia)',
        'target_kcal': menuRow['target_kcal'],
      });

      // associar clientes
      final batchLink = txn.batch();
      for (final cId in targetClientIds) {
        batchLink.insert(
          clientMenusTable.name,
          {'client_id': cId, 'menu_id': newMenuId},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await batchLink.commit(noResult: true);

      // copiar meals
      final mealsRows = await txn.query(
        mealsTable.name,
        where: 'menu_id = ?',
        whereArgs: [sourceMenuId],
      );

      for (final m in mealsRows) {
        final newMealId = await txn.insert(mealsTable.name, {
          'menu_id': newMenuId,
          'name': m['name'],
          'order_index': m['order_index'],
        });

        final mfRows = await txn.query(
          mealFoodsTable.name,
          where: 'meal_id = ?',
          whereArgs: [m['id']],
        );

        final batchFoods = txn.batch();
        for (final mf in mfRows) {
          batchFoods.insert(
            mealFoodsTable.name,
            {
              'meal_id': newMealId,
              'food_id': mf['food_id'],
              'quantity': mf['quantity'],
              'kcal_total': mf['kcal_total'],
              'notes': mf['notes'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batchFoods.commit(noResult: true);
      }

      return newMenuId;
    });
  }

  /// Menus de um cliente com meals e foods agrupados
  Future<List<Map<String, dynamic>>> getMenusByClientWithMealsAndFoods(
      int clientId) async {
    final menus = await _db.database.rawQuery('''
      SELECT m.id as menu_id, m.title, m.target_kcal
      FROM ${menusTable.name} m
      JOIN ${clientMenusTable.name} cm ON cm.menu_id = m.id
      WHERE cm.client_id = ?
      ORDER BY m.id DESC
    ''', [clientId]);

    for (final menu in menus) {
      final menuId = menu['menu_id'] as int;

      final meals = await _db.database.query(
        mealsTable.name,
        where: 'menu_id = ?',
        whereArgs: [menuId],
        orderBy: 'order_index ASC, id ASC',
      );

      final mealsOut = <Map<String, dynamic>>[];
      for (final meal in meals) {
        final mealId = meal['id'] as int;
        final foods = await _db.database.rawQuery('''
          SELECT f.id as food_id, f.name, f.default_portion, f.kcal_per_portion,
                 mf.quantity, mf.kcal_total, mf.notes
          FROM ${mealFoodsTable.name} mf
          JOIN ${foodsTable.name} f ON f.id = mf.food_id
          WHERE mf.meal_id = ?
        ''', [mealId]);

        mealsOut.add({
          'id': mealId,
          'name': meal['name'],
          'orderIndex': meal['order_index'],
          'foods': foods,
        });
      }

      menu['meals'] = mealsOut;
    }

    return menus;
  }

  /// Detalhe de um único menu (para edição)
  Future<Map<String, dynamic>?> getMenuDetail(int menuId) async {
    final menuRows = await _db.database.query(
      menusTable.name,
      where: 'id = ?',
      whereArgs: [menuId],
      limit: 1,
    );
    if (menuRows.isEmpty) return null;
    final menu = menuRows.first;

    final clients = await _db.database.rawQuery('''
      SELECT c.id, c.name FROM ${TableNames.clients.name} c
      JOIN ${clientMenusTable.name} cm ON cm.client_id = c.id
      WHERE cm.menu_id = ?
    ''', [menuId]);

    final meals = await _db.database.query(
      mealsTable.name,
      where: 'menu_id = ?',
      whereArgs: [menuId],
      orderBy: 'order_index ASC, id ASC',
    );

    final mealsOut = <Map<String, dynamic>>[];
    for (final meal in meals) {
      final mealId = meal['id'] as int;
      final foods = await _db.database.rawQuery('''
        SELECT f.id as food_id, f.name, mf.quantity, mf.kcal_total, mf.notes
        FROM ${mealFoodsTable.name} mf
        JOIN ${foodsTable.name} f ON f.id = mf.food_id
        WHERE mf.meal_id = ?
      ''', [mealId]);

      mealsOut.add({
        'id': mealId,
        'name': meal['name'],
        'orderIndex': meal['order_index'],
        'foods': foods,
      });
    }

    return {
      'id': menu['id'],
      'title': menu['title'],
      'target_kcal': menu['target_kcal'],
      'clients': clients,
      'meals': mealsOut,
    };
  }
}

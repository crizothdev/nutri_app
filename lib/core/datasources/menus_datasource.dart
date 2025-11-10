import 'dart:convert';

import 'package:nutri_app/core/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

import 'foods_datasource.dart';

class MenusDatasource {
  final LocalDatabaseService _db;

  // Nomes de tabela centralizados na SQLStrings
  final String menusTable = SQLStrings.tMenus;
  final String clientMenusTable = SQLStrings.tClientMenus;
  final String clientsTable = SQLStrings.tClients;
  // Não existem mais tables de meals/meal_foods

  MenusDatasource(this._db);

  /// Cria um menu e associa a N clientes.
  /// Estrutura esperada:
  /// title, targetKcal, clientIds, meals: [{title, description?, foodIds: [int,int,...]}]
  Future<int> createMenuWithMeals({
    required String title,
    int? targetKcal,
    required List<int> clientIds,
    required List<Map<String, dynamic>> meals,
  }) async {
    return await _db.database.transaction<int>((txn) async {
      final menuId = await txn.insert(menusTable, {
        'title': title,
        'target_kcal': targetKcal,
        'meals_json': jsonEncode(meals),
      });

      // vincular clientes (N:N)
      if (clientIds.isNotEmpty) {
        final linkBatch = txn.batch();
        for (final cId in clientIds) {
          linkBatch.insert(
            clientMenusTable,
            {'client_id': cId, 'menu_id': menuId},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
        await linkBatch.commit(noResult: true);
      }

      return menuId;
    });
  }

  /// Associa um menu existente a novos clientes (N:N)
  Future<void> linkMenuToClients(int menuId, List<int> clientIds) async {
    if (clientIds.isEmpty) return;
    final batch = _db.database.batch();
    for (final cId in clientIds) {
      batch.insert(
        clientMenusTable,
        {'client_id': cId, 'menu_id': menuId},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Substitui a lista de clientes vinculados ao menu (remove os antigos e insere os novos)
  Future<void> setClientsForMenu(int menuId, List<int> clientIds) async {
    await _db.database.transaction((txn) async {
      await txn
          .delete(clientMenusTable, where: 'menu_id = ?', whereArgs: [menuId]);
      if (clientIds.isNotEmpty) {
        final batch = txn.batch();
        for (final cId in clientIds) {
          batch.insert(
            clientMenusTable,
            {'client_id': cId, 'menu_id': menuId},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
        await batch.commit(noResult: true);
      }
      return 0;
    });
  }

  /// Duplica um menu (incluindo meals_json) para outros clientes
  Future<int> duplicateMenuForClients(
    int sourceMenuId,
    List<int> targetClientIds, {
    String? newTitle,
  }) async {
    return await _db.database.transaction<int>((txn) async {
      final menuRow = (await txn.query(
        menusTable,
        where: 'id = ?',
        whereArgs: [sourceMenuId],
        limit: 1,
      ))
          .first;

      final newMenuId = await txn.insert(menusTable, {
        'title': newTitle ?? '${menuRow['title']} (cópia)',
        'target_kcal': menuRow['target_kcal'],
        'meals_json': menuRow['meals_json'],
      });

      if (targetClientIds.isNotEmpty) {
        final batchLink = txn.batch();
        for (final cId in targetClientIds) {
          batchLink.insert(
            clientMenusTable,
            {'client_id': cId, 'menu_id': newMenuId},
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
        await batchLink.commit(noResult: true);
      }

      return newMenuId;
    });
  }

  /// Atualiza apenas campos básicos do menu (title/target_kcal)
  Future<int> updateMenuBasics({
    required int menuId,
    String? title,
    int? targetKcal,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (targetKcal != null) data['target_kcal'] = targetKcal;
    if (data.isEmpty) return 0;
    return _db.updateById(menusTable, {'id': menuId, ...data});
  }

  /// Lê e decodifica o meals_json de um menu (lista de maps).
  Future<List<Map<String, dynamic>>> _readMealsJson(int menuId,
      {Transaction? txn}) async {
    final db = txn ?? _db.database;
    final rows = await db.query(menusTable,
        columns: ['meals_json'],
        where: 'id = ?',
        whereArgs: [menuId],
        limit: 1);
    if (rows.isEmpty) return [];
    final raw = rows.first['meals_json'] as String? ?? '[]';
    final parsed = jsonDecode(raw);
    if (parsed is List) {
      return parsed.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Persiste a lista de meals no menu.
  Future<int> _writeMealsJson(int menuId, List<Map<String, dynamic>> meals,
      {Transaction? txn}) async {
    final db = txn ?? _db.database;
    return db.update(
      menusTable,
      {'meals_json': jsonEncode(meals)},
      where: 'id = ?',
      whereArgs: [menuId],
    );
  }

  /// Adiciona uma meal ao final (retorna o índice adicionado).
  Future<int> addMeal(
    int menuId, {
    required String title,
    String? description,
    List<int> foodIds = const [],
  }) async {
    final meals = await _readMealsJson(menuId);
    final newMeal = {
      'title': title,
      'description': description,
      'foodIds': foodIds,
    };
    meals.add(newMeal);
    await _writeMealsJson(menuId, meals);
    return meals.length - 1;
  }

  /// Atualiza uma meal por índice.
  Future<void> updateMeal(
    int menuId, {
    required int mealIndex,
    String? title,
    String? description,
    List<int>? foodIds,
  }) async {
    final meals = await _readMealsJson(menuId);
    if (mealIndex < 0 || mealIndex >= meals.length) {
      throw RangeError('mealIndex fora do intervalo');
    }
    final meal = Map<String, dynamic>.from(meals[mealIndex]);
    if (title != null) meal['title'] = title;
    if (description != null) meal['description'] = description;
    if (foodIds != null) meal['foodIds'] = foodIds;
    meals[mealIndex] = meal;
    await _writeMealsJson(menuId, meals);
  }

  /// Remove uma meal por índice.
  Future<void> removeMeal(int menuId, int mealIndex) async {
    final meals = await _readMealsJson(menuId);
    if (mealIndex < 0 || mealIndex >= meals.length) return;
    meals.removeAt(mealIndex);
    await _writeMealsJson(menuId, meals);
  }

  /// Substitui apenas os foodIds de uma meal.
  Future<void> setMealFoods(
      int menuId, int mealIndex, List<int> foodIds) async {
    await updateMeal(menuId, mealIndex: mealIndex, foodIds: foodIds);
  }

  /// Exclui o menu (e vínculos N:N)
  Future<int> deleteMenu(int menuId) async {
    await _db.deleteWhere(clientMenusTable,
        where: 'menu_id = ?', whereArgs: [menuId]);
    return _db.deleteData(menusTable, menuId);
  }

  Future<int> deleteMenuForClient(int menuId, int clientId) async {
    return _db.database.transaction<int>((txn) async {
      // Conta quantos clientes estão vinculados a este menu
      final countRow = await txn.rawQuery(
        'SELECT COUNT(*) AS c FROM $clientMenusTable WHERE menu_id = ?',
        [menuId],
      );
      final count = (countRow.first['c'] as int?) ?? 0;
      if (count == 0) {
        // não há vínculos — nada a fazer
        return 0;
      }

      // Remove o vínculo do cliente atual
      final removed = await txn.delete(
        clientMenusTable,
        where: 'menu_id = ? AND client_id = ?',
        whereArgs: [menuId, clientId],
      );

      if (removed == 0) {
        // vínculo não existia
        return 0;
      }

      if (count == 1) {
        // Era o único vínculo — deletar também o menu
        await txn.delete(
          menusTable,
          where: 'id = ?',
          whereArgs: [menuId],
        );
        return 2; // removeu vínculo + deletou menu
      }

      // Ainda há outros clientes usando esse menu — só removemos o vínculo
      return 1; // apenas removeu vínculo
    });
  }

  /// Detalhe de um único menu (para edição) – meals expandidas
  Future<Map<String, dynamic>?> getMenuDetail(
      int menuId, FoodsDatasource foodsDs) async {
    final menuRows = await _db.database.query(
      menusTable,
      where: 'id = ?',
      whereArgs: [menuId],
      limit: 1,
    );
    if (menuRows.isEmpty) return null;
    final menu = menuRows.first;

    final clients = await _db.database.rawQuery('''
      SELECT c.id, c.name 
      FROM $clientsTable c
      JOIN $clientMenusTable cm ON cm.client_id = c.id
      WHERE cm.menu_id = ?
    ''', [menuId]);

    final meals = await _readMealsJson(menuId);
    final mealsOut = <Map<String, dynamic>>[];

    for (final m in meals) {
      final ids = (m['foodIds'] as List?)?.cast<int>() ?? <int>[];
      final foods = await foodsDs.getByIds(ids);
      mealsOut.add({
        ...m,
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

  Future<List<Map<String, dynamic>>> getMenusByClientWithMealsAndFoods(
    int clientId,
    FoodsDatasource foodsDs,
  ) async {
    final rows = await _db.database.rawQuery('''
    SELECT m.id as menu_id, m.title, m.target_kcal, m.meals_json
    FROM $menusTable m
    JOIN $clientMenusTable cm ON cm.menu_id = m.id
    WHERE cm.client_id = ?
    ORDER BY m.id DESC
  ''', [clientId]);

    final out = <Map<String, dynamic>>[];

    for (final row in rows) {
      final mealsJson = (row['meals_json'] as String?) ?? '[]';
      final mealsList = (jsonDecode(mealsJson) as List)
          .map((e) => (e as Map).map((k, v) => MapEntry('$k', v)))
          .toList(); // garante Map<String, dynamic>

      final mealsOut = <Map<String, dynamic>>[];
      for (final m in mealsList) {
        final ids = (m['foodIds'] as List?)?.cast<int>() ?? const <int>[];
        final foods = await foodsDs.getByIds(ids);
        mealsOut.add({...m, 'foods': foods});
      }

      out.add({
        // cópia do row garantindo String,dynamic
        ...row.map((k, v) => MapEntry(k.toString(), v)),
        'meals': mealsOut,
      }..remove('meals_json'));
    }

    return out;
  }

  /// Retorna um menu “cru” (sem expandir meals)
  Future<Map<String, dynamic>?> getMenuByIdRaw(int id) async {
    final rows = await _db.database
        .query(menusTable, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  /// Retorna todos os menus “crus”
  Future<List<Map<String, dynamic>>> getAllMenusRaw() {
    return _db.database.query(menusTable, orderBy: 'id DESC');
  }

  Future<int> updateMealsJson({
    required int menuId,
    required List<Map<String, dynamic>> mealsJsonList,
  }) async {
    final jsonStr = jsonEncode(mealsJsonList);
    return _db.updateData(
      SQLStrings.tMenus,
      {'meals_json': jsonStr},
      where: 'id = ?',
      whereArgs: [menuId],
    );
  }

  Future<int> updateMenu({
    required int id,
    required String title,
    int? targetKcal,
    required List<Map<String, dynamic>> mealsJsonList,
  }) async {
    final jsonStr = jsonEncode(mealsJsonList);
    return _db.updateData(
      SQLStrings.tMenus,
      {
        'title': title,
        'target_kcal': targetKcal,
        'meals_json': jsonStr,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

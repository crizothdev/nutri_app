import 'package:nutri_app/core/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class FoodsDatasource {
  final LocalDatabaseService _db;
  final String _table = SQLStrings.tFoods;

  FoodsDatasource(this._db);

  /// Upsert por [code]. Se existir, substitui; senão, cria.
  Future<int> upsertFood({
    required String code,
    required String name,
    required String defaultPortion,
    required double calories,
  }) async {
    final data = <String, dynamic>{
      'code': code,
      'name': name,
      'default_portion': defaultPortion,
      'calories': calories,
    };

    return _db.insertData(
      _table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Importa uma lista JSON de alimentos (primeira carga).
  /// Campos aceitos:
  /// { code, name, default_portion|portion, calories }
  Future<void> importFoodsFromJson(List<Map<String, dynamic>> foodsJson) async {
    await _db.database.transaction((txn) async {
      final batch = txn.batch();

      for (final f in foodsJson) {
        final code = (f['code'] ?? '').toString();
        if (code.isEmpty) continue;

        final name = (f['name'] ?? '').toString();
        final defaultPortion =
            (f['default_portion'] ?? f['portion'] ?? '').toString();

        final rawCalories = f['calories'];
        final calories = (rawCalories is num)
            ? rawCalories.toDouble()
            : double.tryParse('$rawCalories') ?? 0.0;

        batch.insert(
          _table,
          {
            'code': code,
            'name': name,
            'default_portion': defaultPortion,
            'calories': calories,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  /// Atualiza por ID (parcial)
  Future<int> updateFood(int id, Map<String, dynamic> data) async {
    return _db.updateById(_table, {'id': id, ...data});
  }

  /// Busca por nome
  Future<List<Map<String, dynamic>>> searchFoodsByName(
    String term, {
    int limit = 30,
  }) async {
    final like = '%${term.trim()}%';
    return _db.getData(
      _table,
      where: 'LOWER(name) LIKE LOWER(?)',
      whereArgs: [like],
      orderBy: 'name ASC',
      limit: limit,
    );
  }

  /// Busca por id
  Future<Map<String, dynamic>?> getFoodById(int id) async {
    final result = await _db.getData(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isEmpty ? null : result.first;
  }

  /// Busca por code (único)
  Future<Map<String, dynamic>?> getByCode(String code) async {
    final rows = await _db.getData(
      _table,
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Busca múltiplos por IDs
  Future<List<Map<String, dynamic>>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final placeholders = List.filled(ids.length, '?').join(',');
    return _db.rawQuery(
        'SELECT * FROM $_table WHERE id IN ($placeholders)', ids);
  }

  /// Lista todos
  Future<List<Map<String, dynamic>>> getAll({int? limit, int? offset}) async {
    return _db.getData(
      _table,
      orderBy: 'name ASC',
      limit: limit,
      offset: offset,
    );
  }

  /// Deleta por ID
  Future<int> deleteFood(int id) async {
    return _db.deleteData(_table, id);
  }
}

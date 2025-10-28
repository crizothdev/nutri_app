import 'package:nutri_app/core/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class FoodsDatasource {
  final LocalDatabaseService _db;
  final tableName = TableNames.foods;

  FoodsDatasource(this._db);

  /// Cria ou atualiza um alimento com base no [code]
  Future<int> upsertFood({
    required String code,
    required String name,
    required String defaultPortion,
    required double kcalPerPortion,
  }) async {
    return await _db.insertData(
      tableName,
      {
        'code': code,
        'name': name,
        'default_portion': defaultPortion,
        'kcal_per_portion': kcalPerPortion,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Importa uma lista JSON de alimentos (geralmente na primeira inicialização)
  Future<void> importFoodsFromJson(List<Map<String, dynamic>> foodsJson) async {
    await _db.database.transaction((txn) async {
      final batch = txn.batch();
      for (final f in foodsJson) {
        batch.insert(
          tableName.name,
          {
            'code': f['code'],
            'name': f['name'],
            'default_portion': f['default_portion'] ?? f['portion'] ?? '',
            'kcal_per_portion': (f['kcal_per_portion'] is num)
                ? f['kcal_per_portion']
                : double.tryParse('${f['kcal_per_portion']}') ?? 0.0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Busca alimentos pelo nome
  Future<List<Map<String, dynamic>>> searchFoodsByName(String term,
      {int limit = 30}) async {
    return await _db.getData(
      tableName,
      where: 'name LIKE ?',
      whereArgs: ['%$term%'],
      limit: limit,
    );
  }

  /// Retorna um alimento pelo ID
  Future<Map<String, dynamic>?> getFoodById(int id) async {
    final result = await _db.getData(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isEmpty ? null : result.first;
  }

  /// Deleta um alimento pelo ID
  Future<int> deleteFood(int id) async {
    return await _db.deleteData(tableName, id);
  }
}

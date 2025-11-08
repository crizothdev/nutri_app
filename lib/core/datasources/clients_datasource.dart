import 'package:nutri_app/core/services/database_service.dart';
// Removi o import do sqflite: não é usado aqui.

class ClientsDatasource {
  final LocalDatabaseService _db;
  final tableName = TableNames.clients;

  ClientsDatasource(this._db);

  Future<int> createClient({
    required int userId,
    required String name,
    String? email,
    String? notes,
    String? phone,
    String? weight,
    String? height,
  }) async {
    return await _db.insertData(tableName, {
      'user_id': userId,
      'name': name,
      'email': email,
      'notes': notes,
      'phone': phone,
      'weight': weight,
      'height': height,
    });
  }

  Future<List<Map<String, dynamic>>> listClients({int? userId}) async {
    if (userId == null) return await _db.getData(tableName);
    return await _db.getData(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>?> getClient(int clientId) async {
    final r = await _db.getData(
      tableName,
      where: 'id = ?',
      whereArgs: [clientId],
      limit: 1,
    );
    return r.isEmpty ? null : r.first;
  }

  Future<int> updateClient(
    int id, {
    String? name,
    String? email,
    String? notes,
  }) async {
    final data = <String, Object?>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (notes != null) data['notes'] = notes;

    if (data.isEmpty) return 0; // nada a atualizar
    return await _db.updateById(tableName, data, id: id);
  }

  Future<int> deleteClient(int id) async {
    return await _db.deleteData(tableName, id);
  }
}

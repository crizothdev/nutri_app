import 'package:nutri_app/core/services/database_service.dart';

class SchedulesDatasource {
  final LocalDatabaseService _db;
  final tableName = TableNames.schedules;

  SchedulesDatasource(this._db);

  /// Cria um novo agendamento
  Future<int> createSchedule({
    required int clientId,
    required String dateIso, // formato: "2025-10-20"
    required String title,
    String? description,
  }) async {
    return await _db.insertData(
      tableName,
      {
        'client_id': clientId,
        'date_iso': dateIso,
        'title': title,
        'description': description ?? '',
      },
    );
  }

  /// Retorna os agendamentos de um cliente, com filtro opcional de intervalo de data
  Future<List<Map<String, dynamic>>> getClientSchedules(
    int clientId, {
    String? fromIso,
    String? toIso,
  }) async {
    if (fromIso != null && toIso != null) {
      return await _db.rawQuery('''
        SELECT * FROM ${tableName.name}
        WHERE client_id = ?
          AND date_iso >= ?
          AND date_iso < ?
        ORDER BY date_iso ASC, id DESC
      ''', [clientId, fromIso, toIso]);
    }

    return await _db.getData(
      tableName,
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'date_iso ASC, id DESC',
    );
  }

  /// Busca um agendamento específico pelo ID
  Future<Map<String, dynamic>?> getSchedule(int scheduleId) async {
    final result = await _db.getData(
      tableName,
      where: 'id = ?',
      whereArgs: [scheduleId],
      limit: 1,
    );
    return result.isEmpty ? null : result.first;
  }

  /// Atualiza os campos informados de um agendamento
  Future<int> updateSchedule(
    int id, {
    String? dateIso,
    String? title,
    String? description,
  }) async {
    final data = <String, Object?>{};
    if (dateIso != null) data['date_iso'] = dateIso;
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;

    if (data.isEmpty) return 0; // nada a atualizar

    return await _db.updateById(tableName, data, id: id);
  }

  /// Exclui um agendamento
  Future<int> deleteSchedule(int id) async {
    return await _db.deleteData(tableName, id);
  }
}

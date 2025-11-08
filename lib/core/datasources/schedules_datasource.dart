import 'package:nutri_app/core/services/database_service.dart';

class SchedulesDatasource {
  final LocalDatabaseService _db;
  final tableName = SQLStrings.tSchedules;

  SchedulesDatasource(this._db);

  /// Cria um novo agendamento (clientId é opcional)
  /// dateIso: "YYYY-MM-DD", startTime/endTime: "HH:mm"
  Future<int> createSchedule({
    int? clientId,
    required String patientName,
    String? phoneNumber,
    required String dateIso,
    required String startTime,
    required String endTime,
    String? title,
    String? description,
    String status = 'scheduled', // scheduled|done|canceled
  }) async {
    return await _db.insertData(
      tableName,
      {
        'client_id': clientId,
        'patient_name': patientName,
        'phone_number': phoneNumber,
        'date_iso': dateIso,
        'start_time': startTime,
        'end_time': endTime,
        'title': title,
        'description': description ?? '',
        'status': status,
      },
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

  /// Atualiza campos informados de um agendamento
  Future<int> updateSchedule(
    int id, {
    int? clientId,
    String? patientName,
    String? phoneNumber,
    String? dateIso,
    String? startTime,
    String? endTime,
    String? title,
    String? description,
    String? status,
  }) async {
    final data = <String, Object?>{};
    if (clientId != null) data['client_id'] = clientId;
    if (patientName != null) data['patient_name'] = patientName;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (dateIso != null) data['date_iso'] = dateIso;
    if (startTime != null) data['start_time'] = startTime;
    if (endTime != null) data['end_time'] = endTime;
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status;

    if (data.isEmpty) return 0;
    return await _db.updateById(tableName, data, id: id);
  }

  /// Exclui um agendamento
  Future<int> deleteSchedule(int id) async {
    return await _db.deleteData(tableName, id);
  }

  // --------------------------------------------------------------------------
  // NOVO: listar todos do mês informado (para popular o calendário no front)
  // year: ex. 2025, month: 1..12
  // Retorna todos os agendamentos com date_iso dentro do mês, ordenados por dia/hora
  // --------------------------------------------------------------------------
  Future<List<Map<String, dynamic>>> getMonthSchedules({
    required int year,
    required int month,
  }) async {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');

    final startIso = '$y-$m-01';
    // Truque: usa "primeiro dia do mês seguinte" para BETWEEN aberto no fim
    final nextYear = (month == 12) ? year + 1 : year;
    final nextMonth = (month == 12) ? 1 : month + 1;
    final ny = nextYear.toString().padLeft(4, '0');
    final nm = nextMonth.toString().padLeft(2, '0');
    final endIsoExclusive = '$ny-$nm-01';

    return await _db.rawQuery('''
      SELECT * FROM ${tableName}
      WHERE date_iso >= ? AND date_iso < ?
      ORDER BY date_iso ASC, start_time ASC, id ASC
    ''', [startIso, endIsoExclusive]);
  }
}

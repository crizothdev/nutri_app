import '../../models/schedule.dart';
import '../../services/database_service.dart';
import '../../datasources/schedules_datasource.dart';
import '../schedules_repository.dart';

class SchedulesRepositoryImpl implements SchedulesRepository {
  final LocalDatabaseService db;
  late final SchedulesDatasource _ds;

  SchedulesRepositoryImpl(this.db) {
    _ds = SchedulesDatasource(db);
  }

  @override
  Future<int> create(Schedule s) async {
    return await _ds.createSchedule(
      clientId: s.clientId,
      dateIso: s.dateIso,
      title: s.title,
      description: s.description,
    );
  }

  @override
  Future<List<Schedule>> byClient(int clientId,
      {String? fromIso, String? toIso}) async {
    final rows =
        await _ds.getClientSchedules(clientId, fromIso: fromIso, toIso: toIso);
    return rows.map(Schedule.fromMap).toList();
  }

  @override
  Future<Schedule?> get(int id) async {
    final r = await _ds.getSchedule(id);
    return r == null ? null : Schedule.fromMap(r);
  }

  @override
  Future<void> update(Schedule s) async {
    if (s.id == null)
      throw ArgumentError('Schedule.id é obrigatório para update');
    await _ds.updateSchedule(
      s.id!,
      dateIso: s.dateIso,
      title: s.title,
      description: s.description,
    );
  }

  @override
  Future<void> delete(int id) async {
    await _ds.deleteSchedule(id);
  }
}

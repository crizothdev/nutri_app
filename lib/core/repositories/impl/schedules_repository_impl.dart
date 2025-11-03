import 'package:nutri_app/modules/home/home_page.dart';

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
  Future<int> create(ScheduleModel s) async {
    return await _ds.createSchedule(
      clientId: s.clientId,
      patientName: s.patientName,
      phoneNumber: s.phoneNumber,
      dateIso: s.dateIso,
      startTime: s.startTime,
      endTime: s.endTime,
      title: s.title,
      description: s.description,
      status: s.status,
    );
  }

  @override
  Future<List<ScheduleModel>> get({int? year, int? month}) async {
    final response = await _ds.getMonthSchedules(
        year: year ?? DateTime.now().year,
        month: month ?? DateTime.now().month);

    final List<ScheduleModel> schedules =
        response.map<ScheduleModel>((e) => ScheduleModel.fromMap(e)).toList();
    return schedules.isNotEmpty ? schedules : [];
  }

  @override
  Future<void> update(ScheduleModel s) async {
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

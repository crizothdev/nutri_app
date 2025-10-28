import '../models/schedule.dart';

abstract class SchedulesRepository {
  Future<int> create(Schedule schedule);
  Future<List<Schedule>> byClient(int clientId,
      {String? fromIso, String? toIso});
  Future<Schedule?> get(int id);
  Future<void> update(Schedule schedule);
  Future<void> delete(int id);
}

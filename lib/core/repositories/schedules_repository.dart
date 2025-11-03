import 'package:nutri_app/modules/home/home_page.dart';

import '../models/schedule.dart';

abstract class SchedulesRepository {
  Future<int> create(ScheduleModel schedule);
  Future<dynamic> get({int? year, int? month});
  Future<void> update(ScheduleModel schedule);
  Future<void> delete(int id);
}

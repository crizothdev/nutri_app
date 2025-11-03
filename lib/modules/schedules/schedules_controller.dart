import 'package:flutter/material.dart';
import 'package:nutri_app/app_initializer.dart';
import 'package:nutri_app/core/models/schedule.dart';
import 'package:nutri_app/modules/home/home_page.dart';

class SchedulesController extends ChangeNotifier {
  bool isLoading = false;
  Set<DateTime> markedDays = {};
  List<ScheduleModel> schedules = [];
  final scheduleService = AppInitializer.schedulesRepository;

  toggleLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  getAllSchedules() async {
    try {
      schedules = await scheduleService.get();

      // Process schedules
    } catch (e) {
      // Handle error
    } finally {
      toggleLoading(false);
    }
  }
}

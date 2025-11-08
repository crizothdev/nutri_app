import 'package:flutter/material.dart';
import 'package:nutri_app/app_initializer.dart';
import 'package:nutri_app/core/models/user.dart';
import 'package:nutri_app/core/repositories/schedules_repository.dart';
import 'package:nutri_app/modules/home/home_page.dart';

class HomeController extends ChangeNotifier {
  bool _isLoading = false;
  Set<DateTime> markedDays = {};
  final schedulesRepository = AppInitializer.schedulesRepository;
  late User? user;

  toggleLoading(bool val) {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  bool get isLoading => _isLoading == true;

  newSchedule(ScheduleModel schedule) {
    try {
      schedulesRepository.create(schedule);
    } catch (error) {}
    markedDays.add(schedule.date);
    notifyListeners();
  }

  setUser(User user) {
    this.user = user;
    AppInitializer.appInfo.currentUser = user;
    notifyListeners();
  }
}

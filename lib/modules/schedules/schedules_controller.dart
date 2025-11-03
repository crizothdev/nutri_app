import 'package:flutter/material.dart';

class SchedulesController extends ChangeNotifier {
  bool _isLoading = false;
  Set<DateTime> markedDays = {};
  toggleLoading(bool val) {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  bool get isLoading => _isLoading == true;
}

import 'package:flutter/material.dart';

class FoodMenusController extends ChangeNotifier {
  bool _isLoading = false;
  toggleLoading(bool val) {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  bool get isLoading => _isLoading == true;
}

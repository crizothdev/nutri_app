import 'package:flutter/material.dart';
import 'package:nutri_app/app_initializer.dart';
import 'package:nutri_app/routes.dart';

class LoginController extends ChangeNotifier {
  final _userRepo = AppInitializer.usersRepository;
  bool _isLoading = false;
  toggleLoading(bool val) {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  bool get isLoading => _isLoading == true;

  makeLogin(String username, String password) async {
    toggleLoading(true);
    try {
      final user = await _userRepo.makeLogin(username, password);
      print('Login successful for user: ${user.username}');
      goHome(user);
    } catch (e) {
      // Tratar erro de login
    } finally {
      toggleLoading(false);
    }
  }
}

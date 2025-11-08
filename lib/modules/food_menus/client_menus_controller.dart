import 'package:flutter/material.dart';
import 'package:nutri_app/app_initializer.dart';
import 'package:nutri_app/core/models/menu.dart';

class ClientMenusController extends ChangeNotifier {
  bool _isLoading = false;
  List<Menu> _menus = [];

  final foodRepo = AppInitializer.menusRepository;

  List<Menu> get menus => []; // Placeholder for menus list

  toggleLoading(bool? val) {
    _isLoading = val ?? !_isLoading;
    notifyListeners();
  }

  bool get isLoading => _isLoading == true;

  fetchMenus(int clientId) async {
    toggleLoading(true);
    try {
      foodRepo.byClient(clientId).then((value) {
        _menus = value;
        toggleLoading(false);
      });
    } catch (e) {
      toggleLoading(false);
    } finally {
      toggleLoading(false);
    }
  }

  createAndEditMenu(Menu menu) {
    // Lógica para criar e editar o cardápio
  }
}

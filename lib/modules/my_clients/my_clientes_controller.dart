import 'package:flutter/material.dart';
import 'package:nutri_app/core/models/client.dart';

class MyClientsController extends ChangeNotifier {
  bool _isLoading = false;
  toggleLoading(bool val) {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  bool get isLoading => _isLoading == true;

  createClient(Client client) async {
    toggleLoading(true);
    await Future.delayed(const Duration(seconds: 2));
    // Lógica para salvar o cliente
    toggleLoading(false);
  }
}

/*import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  bool _isLoading = false;
  toggleLoading(bool val) {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  bool get isLoading => _isLoading == true;
}*/

import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  bool _isLoading = false;

  toggleLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  // Dados simulados do usuário (em uma versão futura, podem vir de uma API)
  String name = "Maria Eduarda de Castro";
  String email = "nutri.maria@mail.com";
  String phone = "(12) 99100-0000";
  String address = "Rua: Souza Alves, 135 Centro";

  void updateProfile({
    required String newName,
    required String newEmail,
    required String newPhone,
    required String newAddress,
  }) {
    name = newName;
    email = newEmail;
    phone = newPhone;
    address = newAddress;
    notifyListeners();
  }
}

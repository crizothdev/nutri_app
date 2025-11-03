import 'package:flutter/material.dart';
import 'package:nutri_app/app_initializer.dart';
import 'package:nutri_app/core/datasources/user_datasource.dart';
import 'package:nutri_app/core/models/user.dart';
import 'package:nutri_app/core/services/database_service.dart';

class SignupController extends ChangeNotifier {
  final dbService = LocalDatabaseService();
  late UserDatasource userDatasource;
  bool isLoading = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController documentController = TextEditingController();

  toggleLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  onInit() async {
    dbService.database = await dbService.openDB();
    userDatasource = UserDatasource(dbService);
  }

  createUser() async {
    await AppInitializer.usersRepository.create(
      User(
        name: usernameController.text,
        username: usernameController.text,
        password: passwordController.text,
        email: emailController.text,
        phone: phoneController.text,
        document: documentController.text,
      ),
    );
  }
  // Criar um usuário

  // Buscar todos
  getUsers() async {
    final users = await userDatasource.getAllUsers();
    print(users);
  }

  // Buscar por nome
  getUserByName() async {
    final user = await userDatasource.getUserByUsername('cristiano');
    print(user);
  }

  // Atualizar senha
  updatePassword(Map<String, dynamic> user) async {
    await userDatasource.updatePassword(user['id'], 'novaSenha123');
  }

  // Deletar
  deleteUser(Map<String, dynamic> user) async {
    if (user != null) {
      await userDatasource.deleteUser(user['id']);
    }
  }
}

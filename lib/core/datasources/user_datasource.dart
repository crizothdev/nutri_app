import 'package:nutri_app/core/models/user.dart';
import 'package:nutri_app/core/services/database_service.dart';

class UserDatasource {
  final LocalDatabaseService _db;

  UserDatasource(this._db);
  final tableName = TableNames.users;

  /// Criar usuário (falha se username já existir)
  Future<int> createUser(User user) async {
    _validateUsername(user.username!);
    _validatePassword(user.password);

    final existing = await getUserByUsername(user.username!);
    if (existing != null) {
      throw Exception('Já existe um usuário com esse username.');
    }

    return await _db.insertData(
      tableName,
      user.toMap(),
    );
  }

  /// Buscar todos os usuários
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _db.getData(TableNames.users);
  }

  /// Buscar usuário por ID
  Future<Map<String, dynamic>?> getUserById(int id) async {
    final result = await _db.getData(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Buscar usuário por nome
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final result = await _db.getData(
      tableName,
      where: 'username = ?',
      whereArgs: [username.trim()],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Atualizar senha do usuário
  Future<int> updatePassword(int id, String newPassword) async {
    _validatePassword(newPassword);
    return await _db.updateById(
      tableName,
      {'id': id, 'password': newPassword},
    );
  }

  /// Atualizar username (verifica duplicidade)
  Future<int> updateUsername(int id, String newUsername) async {
    _validateUsername(newUsername);

    final existing = await getUserByUsername(newUsername);
    if (existing != null && existing['id'] != id) {
      throw Exception('Username já em uso por outro usuário.');
    }

    return await _db.updateById(
      tableName,
      {'id': id, 'username': newUsername.trim()},
    );
  }

  /// Excluir usuário
  Future<int> deleteUser(int id) async {
    return await _db.deleteData(TableNames.users, id);
  }

  // --------- helpers ---------
  void _validateUsername(String username) {
    if (username.trim().isEmpty) {
      throw Exception('Username não pode ser vazio.');
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw Exception('Senha não pode ser vazia.');
    }
  }

  makeLogin(String username, String password) async {
    final user = await getUserByUsername(username);
    if (user == null || user['password'] != password) {
      throw Exception('Credenciais inválidas.');
    }
    return user;
  }
}

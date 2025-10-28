import '../../models/user.dart';
import '../../services/database_service.dart';
import '../../datasources/user_datasource.dart';
import '../users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  final LocalDatabaseService db;
  late final UserDatasource _ds;

  UsersRepositoryImpl(this.db) {
    _ds = UserDatasource(db);
  }

  @override
  Future<int> create(User user) async {
    return await _ds.createUser(user);
  }

  @override
  Future<List<User>> all() async {
    final rows = await _ds.getAllUsers();
    return rows.map(User.fromMap).toList();
  }

  @override
  Future<User?> byUsername(String username) async {
    final r = await _ds.getUserByUsername(username);
    return r == null ? null : User.fromMap(r);
  }

  @override
  Future<void> updatePassword(int userId, String newPassword) async {
    await _ds.updatePassword(userId, newPassword);
  }

  @override
  Future<void> delete(int userId) async {
    await _ds.deleteUser(userId);
  }
}

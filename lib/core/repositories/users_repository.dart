import '../models/user.dart';

abstract class UsersRepository {
  Future<int> create(User user);
  Future<List<User>> all();
  Future<User?> byUsername(String username);
  Future<void> updatePassword(int userId, String newPassword);
  Future<void> delete(int userId);
}

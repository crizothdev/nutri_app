import '../models/client.dart';

abstract class ClientsRepository {
  Future<int> create({required int userId, required Client client});
  Future<List<Client>> list({int? userId});
  Future<Client?> get(int id);
  Future<void> update(Client client);
  Future<void> delete(int id);
}

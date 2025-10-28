import '../../models/client.dart';
import '../../services/database_service.dart';
import '../../datasources/clients_datasource.dart';
import '../clients_repository.dart';

class ClientsRepositoryImpl implements ClientsRepository {
  final LocalDatabaseService db;
  late final ClientsDatasource _ds;

  ClientsRepositoryImpl(this.db) {
    _ds = ClientsDatasource(db);
  }

  @override
  Future<int> create(Client client) async {
    return await _ds.createClient(
      userId: client.userId,
      name: client.name,
      email: client.email,
      notes: client.notes,
    );
  }

  @override
  Future<List<Client>> list({int? userId}) async {
    final rows = await _ds.listClients(userId: userId);
    return rows.map(Client.fromMap).toList();
  }

  @override
  Future<Client?> get(int id) async {
    final r = await _ds.getClient(id);
    return r == null ? null : Client.fromMap(r);
  }

  @override
  Future<void> update(Client client) async {
    if (client.id == null)
      throw ArgumentError('Client.id é obrigatório para update');
    await _ds.updateClient(client.id!,
        name: client.name, email: client.email, notes: client.notes);
  }

  @override
  Future<void> delete(int id) async {
    await _ds.deleteClient(id);
  }
}

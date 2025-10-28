import '../models/menu.dart';
import '../models/aggregates/menu_aggregate.dart';
import '../models/aggregates/menu_aggregate_input.dart';

abstract class MenusRepository {
  Future<int> createAggregate(MenuAggregateInput input);
  Future<void> linkToClients(int menuId, List<int> clientIds);
  Future<int> duplicateForClients(int sourceMenuId, List<int> targetClientIds,
      {String? newTitle});
  Future<List<Menu>> byClient(int clientId);
  Future<MenuAggregate?> aggregate(int menuId);
}

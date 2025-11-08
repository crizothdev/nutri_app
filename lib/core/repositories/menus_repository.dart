import '../models/menu.dart';
import '../models/aggregates/menu_aggregate.dart';
import '../models/aggregates/menu_aggregate_input.dart';

/// Repositório de Menus (meals embutidas em `meals_json`).
abstract class MenusRepository {
  /// Cria um menu completo (aggregate) a partir do input (inclui meals e vínculo com clientes).
  Future<int> createAggregate(MenuAggregateInput input);

  /// Vincula um menu existente a clientes (N:N). Não remove vínculos antigos.
  Future<void> linkToClients(int menuId, List<int> clientIds);

  /// Duplica um menu (inclui meals) e vincula aos clientes-alvo.
  /// Se [newTitle] for informado, usa-o no menu duplicado.
  Future<int> duplicateForClients(
    int sourceMenuId,
    List<int> targetClientIds, {
    String? newTitle,
  });

  /// Lista menus de um cliente (retorno leve: apenas dados do Menu).
  Future<List<Menu>> byClient(int clientId);

  /// Retorna o agregado completo (menu + meals + foods + clientes).
  Future<MenuAggregate?> aggregate(int menuId);
}

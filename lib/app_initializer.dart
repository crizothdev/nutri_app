import 'package:nutri_app/core/services/database_service.dart';
import 'package:nutri_app/core/repositories/impl/users_repository_impl.dart';
import 'package:nutri_app/core/repositories/impl/clients_repository_impl.dart';
import 'package:nutri_app/core/repositories/impl/foods_repository_impl.dart';
import 'package:nutri_app/core/repositories/impl/meals_repository_impl.dart';
import 'package:nutri_app/core/repositories/impl/menus_repository_impl.dart';
import 'package:nutri_app/core/repositories/impl/schedules_repository_impl.dart';
import 'package:sqflite/sqflite.dart';

import 'package:nutri_app/core/data/alimentos_com_imagens.dart' as data;

class AppInitializer {
  static bool _inited = false;
  static late final LocalDatabaseService db;

  static late final UsersRepositoryImpl usersRepository;
  static late final ClientsRepositoryImpl clientsRepository;
  static late final FoodsRepositoryImpl foodsRepository;
  static late final MealsRepositoryImpl mealsRepository;
  static late final MenusRepositoryImpl menusRepository;
  static late final SchedulesRepositoryImpl schedulesRepository;

  static Future<void> init() async {
    if (_inited) return;
    _inited = true;

    db = LocalDatabaseService();
    await db.openDB();

    usersRepository = UsersRepositoryImpl(db);
    clientsRepository = ClientsRepositoryImpl(db);
    foodsRepository = FoodsRepositoryImpl(db);
    mealsRepository = MealsRepositoryImpl(db);
    menusRepository = MenusRepositoryImpl(db);
    schedulesRepository = SchedulesRepositoryImpl(db);

    await _maybeImportDefaultFoods(db);
  }

  static Future<void> _maybeImportDefaultFoods(
      LocalDatabaseService dbInstance) async {
    int? count;
    try {
      count = Sqflite.firstIntValue(
        await dbInstance.database.rawQuery('SELECT COUNT(*) FROM foods'),
      );
    } catch (e) {
      print('Error occurred while counting foods: $e');
    }

    if (count == 0 || count == null) {
      await foodsRepository.importFromAppJson(data.alimentos);
      // Opcional: logar no console
      // ignore: avoid_print
      print('🍚 Base de alimentos padrão importada com sucesso.');
    } else {
      // ignore: avoid_print
      print(
          '📦 Tabela foods já possui $count registros. Nenhuma importação necessária.');
    }
  }
}

// get usersRepository => AppInitializer.usersRepository;
// get clientsRepository => AppInitializer.clientsRepository;
// get foodsRepository => AppInitializer.foodsRepository;
// get mealsRepository => AppInitializer.mealsRepository;
// get menusRepository => AppInitializer.menusRepository;
// get  schedulesRepository => AppInitializer.schedulesRepository;

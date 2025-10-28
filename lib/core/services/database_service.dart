import 'package:sqflite/sqflite.dart';

enum TableNames {
  users,
  clients,
  menus,
  client_menus,
  meals,
  foods,
  meal_foods,
  schedules,
}

class LocalDatabaseService {
  late Database database;

  Future<Database> openDB() async {
    database = await openDatabase(
      'nutri_app_database.db',
      version: 2,
      onCreate: (Database db, int version) async {
        await createTables(db);
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await _migrateToV2(db);
        }
      },
    );

    return database;
  }

  Future<void> createTables(Database database) async {
    // users
    await database.execute('''
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    username TEXT NOT NULL,
    password TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    document TEXT
  )
''');
// (opcional, mas recomendado)
    await database.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS ux_users_username ON users(username)');
    await database.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS ux_users_document ON users(document)');

    // clients
    await database.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT,
        email TEXT,
        notes TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // menus (sem client_id já na criação nova)
    await database.execute('''
      CREATE TABLE menus (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        target_kcal INTEGER
      )
    ''');

    // Tabela de associação muitos-para-muitos
    await database.execute('''
      CREATE TABLE client_menus (
        client_id INTEGER NOT NULL,
        menu_id INTEGER NOT NULL,
        PRIMARY KEY (client_id, menu_id),
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
        FOREIGN KEY (menu_id) REFERENCES menus(id) ON DELETE CASCADE
      )
    ''');

    // meals
    await database.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        menu_id INTEGER NOT NULL,
        name TEXT,
        order_index INTEGER,
        FOREIGN KEY (menu_id) REFERENCES menus(id) ON DELETE CASCADE
      )
    ''');

    // foods
    await database.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE,
        name TEXT,
        default_portion TEXT,
        kcal_per_portion REAL
      )
    ''');

    // meal_foods
    await database.execute('''
      CREATE TABLE meal_foods (
        meal_id INTEGER NOT NULL,
        food_id INTEGER NOT NULL,
        quantity REAL,
        kcal_total REAL,
        notes TEXT,
        PRIMARY KEY (meal_id, food_id),
        FOREIGN KEY (meal_id) REFERENCES meals(id) ON DELETE CASCADE,
        FOREIGN KEY (food_id) REFERENCES foods(id) ON DELETE RESTRICT
      )
    ''');

    // schedules (já com title)
    await database.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        date_iso TEXT,
        title TEXT,
        description TEXT,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
      )
    ''');

    // Índices úteis
    await database
        .execute('CREATE INDEX IF NOT EXISTS idx_meals_menu ON meals(menu_id)');
    await database.execute(
        'CREATE INDEX IF NOT EXISTS idx_mealfoods_meal ON meal_foods(meal_id)');
    await database.execute(
        'CREATE INDEX IF NOT EXISTS idx_clientmenus_client ON client_menus(client_id)');
  }

  Future<void> _migrateToV2(Database db) async {
    // 1) Garantir colunas novas em schedules
    final schedulesInfo = await db.rawQuery("PRAGMA table_info('schedules')");
    final hasTitle = schedulesInfo.any((c) => (c['name'] as String) == 'title');
    if (!hasTitle) {
      await db.execute("ALTER TABLE schedules ADD COLUMN title TEXT");
    }

    // 2) Migrar client_id de menus para client_menus e remover client_id de menus
    // Detectar se menus tem client_id
    final menusInfo = await db.rawQuery("PRAGMA table_info('menus')");
    final hadClientId =
        menusInfo.any((c) => (c['name'] as String) == 'client_id');

    if (hadClientId) {
      // Criar client_menus se não existir
      await db.execute('''
        CREATE TABLE IF NOT EXISTS client_menus (
          client_id INTEGER NOT NULL,
          menu_id INTEGER NOT NULL,
          PRIMARY KEY (client_id, menu_id),
          FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
          FOREIGN KEY (menu_id) REFERENCES menus(id) ON DELETE CASCADE
        )
      ''');

      // Backfill: para cada menu com client_id, criar vínculo em client_menus
      final rows = await db.rawQuery(
          'SELECT id, client_id FROM menus WHERE client_id IS NOT NULL');
      final batch = db.batch();
      for (final r in rows) {
        batch.insert(
            'client_menus',
            {
              'client_id': r['client_id'],
              'menu_id': r['id'],
            },
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);

      // Remover client_id de menus (recriar tabela menus sem client_id)
      await db.execute('ALTER TABLE menus RENAME TO menus_old');
      await db.execute('''
        CREATE TABLE menus (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          target_kcal INTEGER
        )
      ''');
      await db.execute('''
        INSERT INTO menus (id, title, target_kcal)
        SELECT id, title, target_kcal FROM menus_old
      ''');
      await db.execute('DROP TABLE menus_old');
    }

    // Índices
    await db
        .execute('CREATE INDEX IF NOT EXISTS idx_meals_menu ON meals(menu_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_mealfoods_meal ON meal_foods(meal_id)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_clientmenus_client ON client_menus(client_id)');
  }

  // ---------------------------
  // CRUD genéricos
  // ---------------------------

  /// Insert genérico
  Future<int> insertData(
    TableNames table,
    Map<String, dynamic> data, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    return await database.insert(table.name, data,
        conflictAlgorithm: conflictAlgorithm);
  }

  /// Query genérico
  Future<List<Map<String, dynamic>>> getData(
    TableNames table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
    bool distinct = false,
  }) async {
    return await database.query(
      table.name,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
      distinct: distinct,
    );
  }

  /// Update genérico (com cláusula custom)
  Future<int> updateData(
    TableNames table,
    Map<String, dynamic> data, {
    required String where,
    required List<Object?> whereArgs,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    return await database.update(
      table.name,
      data,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// Conveniência: update por ID (espera que [data] contenha 'id' ou recebe via parâmetro)
  Future<int> updateById(
    TableNames table,
    Map<String, dynamic> data, {
    int? id,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    final targetId = id ?? data['id'];
    if (targetId == null) {
      throw ArgumentError('updateById requer "id" no map ou no parâmetro id.');
    }
    final patched = Map<String, dynamic>.from(data)..remove('id');
    return await updateData(
      table,
      patched,
      where: 'id = ?',
      whereArgs: [targetId],
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// Delete por ID
  Future<int> deleteData(TableNames table, int id) async {
    return await database.delete(table.name, where: 'id = ?', whereArgs: [id]);
  }

  /// Delete com cláusula custom
  Future<int> deleteWhere(
    TableNames table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    return await database.delete(table.name,
        where: where, whereArgs: whereArgs);
  }

  // ---------------------------
  // Helpers adicionais
  // ---------------------------

  Future<List<Map<String, Object?>>> rawQuery(String sql,
      [List<Object?>? args]) {
    return database.rawQuery(sql, args);
  }

  Future<void> rawExecute(String sql, [List<Object?>? args]) async {
    await database.execute(sql, args);
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) {
    return database.transaction(action);
  }

  Future<void> close() async {
    await database.close();
  }

  bool get isOpen => database.isOpen;
}

import 'package:sqflite/sqflite.dart';

/// Centraliza nomes de tabelas e instruções SQL.
class SQLStrings {
  // --------- TABLE NAMES ---------
  static const tUsers = 'users';
  static const tClients = 'clients';
  static const tMenus = 'menus';
  static const tClientMenus = 'client_menus';
  static const tFoods = 'foods';
  static const tSchedules = 'schedules';

  // --------- CREATE TABLES ---------
  static String createUsers() => '''
    CREATE TABLE $tUsers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      email TEXT,
      phone TEXT,
      document TEXT
    )
  ''';

  static String uxUsersUsername() =>
      'CREATE UNIQUE INDEX IF NOT EXISTS ux_${tUsers}_username ON $tUsers(username)';

  static String uxUsersDocument() =>
      'CREATE UNIQUE INDEX IF NOT EXISTS ux_${tUsers}_document ON $tUsers(document)';

  static String createClients() => '''
    CREATE TABLE $tClients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      name TEXT,
      email TEXT,
      phone TEXT,
      weight TEXT,
      height TEXT,
      notes TEXT,
      FOREIGN KEY (user_id) REFERENCES $tUsers(id) ON DELETE CASCADE
    )
  ''';

  /// MENUS com meals embutidas em JSON
  static String createMenus() => '''
    CREATE TABLE $tMenus (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      target_kcal INTEGER,
      meals_json TEXT NOT NULL DEFAULT '[]' -- [{title,description,foodIds:[...]}]
    )
  ''';

  /// Relação N:N entre clients e menus
  static String createClientMenus() => '''
    CREATE TABLE $tClientMenus (
      client_id INTEGER NOT NULL,
      menu_id INTEGER NOT NULL,
      PRIMARY KEY (client_id, menu_id),
      FOREIGN KEY (client_id) REFERENCES $tClients(id) ON DELETE CASCADE,
      FOREIGN KEY (menu_id) REFERENCES $tMenus(id) ON DELETE CASCADE
    )
  ''';

  /// Catálogo de alimentos
  static String createFoods() => '''
    CREATE TABLE $tFoods (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT UNIQUE,
      name TEXT,
      default_portion TEXT,
      kcal_per_portion REAL,
      calories INTEGER -- kcal (opcional)
    )
  ''';

  /// Agenda (desnormalizada)
  static String createSchedules() => '''
    CREATE TABLE $tSchedules (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      client_id INTEGER NULL,
      patient_name TEXT NOT NULL,
      phone_number TEXT,
      date_iso TEXT NOT NULL,     -- "YYYY-MM-DD"
      start_time TEXT NOT NULL,   -- "HH:mm"
      end_time TEXT NOT NULL,     -- "HH:mm"
      title TEXT,
      description TEXT,
      status TEXT DEFAULT 'scheduled',
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (client_id) REFERENCES $tClients(id) ON DELETE SET NULL
    )
  ''';

  // --------- INDEXES ---------
  static String idxSchedulesDate() =>
      'CREATE INDEX IF NOT EXISTS idx_${tSchedules}_date ON $tSchedules(date_iso)';

  static String idxSchedulesDateStart() =>
      'CREATE INDEX IF NOT EXISTS idx_${tSchedules}_date_start ON $tSchedules(date_iso, start_time)';

  static String idxClientMenusClient() =>
      'CREATE INDEX IF NOT EXISTS idx_${tClientMenus}_client ON $tClientMenus(client_id)';
}

class LocalDatabaseService {
  late Database database;

  Future<Database> openDB() async {
    database = await openDatabase(
      'nutri_app_database.db',
      version: 1,
      onCreate: (db, _) async => createTables(db),
    );
    return database;
  }

  Future<void> createTables(Database db) async {
    await db.execute(SQLStrings.createUsers());
    await db.execute(SQLStrings.uxUsersUsername());
    await db.execute(SQLStrings.uxUsersDocument());

    await db.execute(SQLStrings.createClients());

    await db.execute(SQLStrings.createMenus());
    await db.execute(SQLStrings.createClientMenus());

    await db.execute(SQLStrings.createFoods());

    await db.execute(SQLStrings.createSchedules());
    await db.execute(SQLStrings.idxSchedulesDate());
    await db.execute(SQLStrings.idxSchedulesDateStart());
    await db.execute(SQLStrings.idxClientMenusClient());
  }

  // ---------------------------
  // CRUD genéricos (table = nome da tabela)
  // ---------------------------
  Future<int> insertData(
    String table,
    Map<String, dynamic> data, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    return await database.insert(table, data,
        conflictAlgorithm: conflictAlgorithm);
  }

  Future<List<Map<String, dynamic>>> getData(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
    bool distinct = false,
  }) async {
    return await database.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
      distinct: distinct,
    );
  }

  Future<int> updateData(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<Object?> whereArgs,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort,
  }) async {
    return await database.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<int> updateById(
    String table,
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

  Future<int> deleteData(String table, int id) async {
    return await database.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteWhere(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    return await database.delete(table, where: where, whereArgs: whereArgs);
  }

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

  Future<void> close() async => database.close();

  bool get isOpen => database.isOpen;
}

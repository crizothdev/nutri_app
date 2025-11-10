// lib/core/data/demo_seeder.dart
import 'dart:convert';
import 'package:nutri_app/core/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class DemoSeeder {
  static const int _demoUserId = 999;

  static Future<void> ensureDemo(LocalDatabaseService db) async {
    final exists = await _userExists(db, _demoUserId);
    if (exists) return;

    await db.transaction((txn) async {
      // 1) Usuário demo
      await txn.insert(
        SQLStrings.tUsers,
        {
          'id': _demoUserId,
          'name': 'Nutricionista Teste',
          'username': 'teste',
          'password': '123456',
          'email': 'nutri.teste@nutriapp.local',
          'phone': '+55 11 90000-1000',
          'document': '111.111.111-11',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2) Clientes
      final anaId = await txn.insert(SQLStrings.tClients, {
        'user_id': _demoUserId,
        'name': 'Ana Martins',
        'email': 'ana.martins@cliente.com',
        'phone': '+55 11 98888-1001',
        'weight': '64',
        'height': '1.65',
        'notes': 'Objetivo: ganho de massa magra',
      });

      final brunoId = await txn.insert(SQLStrings.tClients, {
        'user_id': _demoUserId,
        'name': 'Bruno Silva',
        'email': 'bruno.s@cliente.com',
        'phone': '+55 11 98888-1002',
        'weight': '82',
        'height': '1.80',
        'notes': 'Objetivo: emagrecimento',
      });

      final carlaId = await txn.insert(SQLStrings.tClients, {
        'user_id': _demoUserId,
        'name': 'Carla Oliveira',
        'email': 'carla.oliveira@cliente.com',
        'phone': '+55 11 98888-1003',
        'weight': '71',
        'height': '1.73',
        'notes': 'Objetivo: reeducação alimentar',
      });

      // 3) Menus COM meals_json
      // Helpers de lookup (código = slug do nome, ex.: arroz-branco, feijao-carioca, frango-grelhado)
      Future<int?> foodIdByCode(String code) async {
        final r = await txn.query(
          SQLStrings.tFoods,
          columns: ['id'],
          where: 'code = ?',
          whereArgs: [code],
          limit: 1,
        );
        if (r.isEmpty) return null;
        return (r.first['id'] as int);
      }

      Future<List<int>> ids(List<String> codes) async {
        final out = <int>[];
        for (final c in codes) {
          final id = await foodIdByCode(c);
          if (id != null) out.add(id);
        }
        return out;
      }

      // Plano Low Carb
      final lowCarbMeals = [
        {
          'title': 'Café da manhã',
          'description': 'Ovos e queijo',
          'foodIds': await ids(['ovos-cozidos', 'queijo-minas']),
        },
        {
          'title': 'Almoço',
          'description': 'Frango + salada + legumes',
          'foodIds':
              await ids(['frango-grelhado', 'alface', 'brocolis-no-vapor']),
        },
        {
          'title': 'Jantar',
          'description': 'Peixe e legumes',
          'foodIds':
              await ids(['peixe-tilapia-grelhada', 'abobrinha-refogada']),
        },
      ];

      final menuLowCarb = await txn.insert(
        SQLStrings.tMenus,
        {
          'title': 'Plano Low Carb',
          'target_kcal': 1800,
          'meals_json': jsonEncode(lowCarbMeals),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Plano de Hipertrofia
      final hiperMeals = [
        {
          'title': 'Café da manhã',
          'description': 'Café com leite, pão integral e ovos',
          'foodIds':
              await ids(['cafe-com-leite', 'pao-integral', 'ovos-cozidos']),
        },
        {
          'title': 'Almoço',
          'description': 'Arroz, feijão e frango',
          'foodIds':
              await ids(['arroz-branco', 'feijao-carioca', 'frango-grelhado']),
        },
        {
          'title': 'Lanche',
          'description': 'Iogurte e banana',
          'foodIds': await ids(['iogurte-natural', 'banana-prata']),
        },
      ];

      final menuHipertrofia = await txn.insert(
        SQLStrings.tMenus,
        {
          'title': 'Plano de Hipertrofia',
          'target_kcal': 2300,
          'meals_json': jsonEncode(hiperMeals),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Plano de Reeducação Alimentar
      final reeduMeals = [
        {
          'title': 'Café da manhã',
          'description': 'Cuscuz com ovo',
          'foodIds': await ids(['cuscuz-nordestino', 'ovos-cozidos']),
        },
        {
          'title': 'Almoço',
          'description': 'Arroz integral, feijão e carne moída',
          'foodIds': await ids(
              ['arroz-integral', 'feijao-preto', 'carne-moida-refogada']),
        },
        {
          'title': 'Jantar',
          'description': 'Sopa leve',
          'foodIds': await ids(['sopa-de-legumes']),
        },
      ];

      final menuReeducacao = await txn.insert(
        SQLStrings.tMenus,
        {
          'title': 'Plano de Reeducação Alimentar',
          'target_kcal': 2000,
          'meals_json': jsonEncode(reeduMeals),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 4) Vínculos — 2 menus por cliente (compartilhados)
      // Ana → Hipertrofia e Reeducação
      await txn.insert(SQLStrings.tClientMenus,
          {'client_id': anaId, 'menu_id': menuHipertrofia},
          conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.insert(SQLStrings.tClientMenus,
          {'client_id': anaId, 'menu_id': menuReeducacao},
          conflictAlgorithm: ConflictAlgorithm.ignore);

      // Bruno → Low Carb e Reeducação
      await txn.insert(SQLStrings.tClientMenus,
          {'client_id': brunoId, 'menu_id': menuLowCarb},
          conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.insert(SQLStrings.tClientMenus,
          {'client_id': brunoId, 'menu_id': menuReeducacao},
          conflictAlgorithm: ConflictAlgorithm.ignore);

      // Carla → Low Carb e Hipertrofia
      await txn.insert(SQLStrings.tClientMenus,
          {'client_id': carlaId, 'menu_id': menuLowCarb},
          conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.insert(SQLStrings.tClientMenus,
          {'client_id': carlaId, 'menu_id': menuHipertrofia},
          conflictAlgorithm: ConflictAlgorithm.ignore);

      // 5) Agendamentos
      final today = DateTime.now();
      String d(int plusDays) =>
          DateTime(today.year, today.month, today.day + plusDays)
              .toIso8601String()
              .substring(0, 10);

      await txn.insert(SQLStrings.tSchedules, {
        'client_id': anaId,
        'patient_name': 'Ana Martins',
        'phone_number': '+55 11 98888-1001',
        'date_iso': d(1),
        'start_time': '09:00',
        'end_time': '09:30',
        'title': 'Avaliação inicial',
        'description': 'Medições, anamnese e metas',
        'status': 'scheduled',
      });

      await txn.insert(SQLStrings.tSchedules, {
        'client_id': brunoId,
        'patient_name': 'Bruno Silva',
        'phone_number': '+55 11 98888-1002',
        'date_iso': d(2),
        'start_time': '10:00',
        'end_time': '10:30',
        'title': 'Retorno 1',
        'description': 'Ajustes de dieta e metas',
        'status': 'scheduled',
      });

      await txn.insert(SQLStrings.tSchedules, {
        'client_id': carlaId,
        'patient_name': 'Carla Oliveira',
        'phone_number': '+55 11 98888-1003',
        'date_iso': d(3),
        'start_time': '11:00',
        'end_time': '11:30',
        'title': 'Revisão de progresso',
        'description': 'Conferência de resultados',
        'status': 'scheduled',
      });
    });
  }

  static Future<bool> _userExists(LocalDatabaseService db, int id) async {
    final rows = await db.getData(
      SQLStrings.tUsers,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}

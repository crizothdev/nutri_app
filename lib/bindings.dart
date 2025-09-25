import 'package:flutter/material.dart';

class AppBindings {
  AppBindings._newInstance();
  static final AppBindings I = AppBindings._newInstance();

  final Map<Type, ChangeNotifier> _map = {};

  /// Pega existente ou cria/guarda
  T get<T extends ChangeNotifier>(T Function() create) {
    final existing = _map[T];
    if (existing != null) return existing as T;
    final inst = create();
    _map[T] = inst;
    return inst;
  }

  /// Já possui?
  bool has<T extends ChangeNotifier>() => _map.containsKey(T);

  /// Substitui/força set
  T put<T extends ChangeNotifier>(T instance) {
    _map[T]?.dispose();
    _map[T] = instance;
    return instance;
  }

  /// Remove (opcionalmente faz dispose)
  void remove<T extends ChangeNotifier>({bool dispose = true}) {
    final inst = _map.remove(T);
    if (dispose) inst?.dispose();
  }

  /// Dispose geral (ex.: logout/app close)
  void disposeAll() {
    for (final e in _map.values) {
      e.dispose();
    }
    _map.clear();
  }
}

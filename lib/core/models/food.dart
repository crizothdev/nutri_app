/// Campos extras abaixo (categorias/description/imgUrl) **não** estão no DB,
/// mas ajudam a UI. Persistimos apenas os do schema.
class Food {
  final int? id;
  final String code;
  final String name;
  final String defaultPortion;
  final double calories; // kcal por porção padrão

  // Não persistidos (úteis para a UI quando vierem do JSON do app)
  final List<String>? categorias;
  final String? description;
  final String? imgUrl;

  const Food({
    this.id,
    required this.code,
    required this.name,
    required this.defaultPortion,
    required this.calories,
    this.categorias,
    this.description,
    this.imgUrl,
  });

  Food copyWith({
    int? id,
    String? code,
    String? name,
    String? defaultPortion,
    double? calories,
    List<String>? categorias,
    String? description,
    String? imgUrl,
  }) =>
      Food(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        defaultPortion: defaultPortion ?? this.defaultPortion,
        calories: calories ?? this.calories,
        categorias: categorias ?? this.categorias,
        description: description ?? this.description,
        imgUrl: imgUrl ?? this.imgUrl,
      );

  /// Mapa para persistência no DB (tabela `foods`):
  /// columns: id, code, name, default_portion, calories
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'code': code,
        'name': name,
        'default_portion': defaultPortion,
        'calories': calories,
      };

  factory Food.fromMap(Map<String, dynamic> m) => Food(
        id: m['id'] as int?,
        code: m['code'] as String,
        name: m['name'] as String,
        defaultPortion: m['default_portion'] as String,
        calories: (m['calories'] as num).toDouble(),
      );

  /// Mapper útil para o JSON de `alimentos_com_imagens.dart`
  /// Exemplo de entrada:
  /// { "nome":"Arroz branco","porcao":"100g","categorias":[...],"description":"...","imgUrl":"...","calories":130 }
  /// - `code`: slug do nome
  /// - `calories`: aceita `calories` (preferido) ou `kcal_per_portion`/`kcal` como fallback
  factory Food.fromAppJson(Map<String, dynamic> j) => Food(
        code: _slug(j['nome'] ?? j['name'] ?? 'food'),
        name: (j['nome'] ?? j['name'] ?? '').toString(),
        defaultPortion: (j['porcao'] ?? j['default_portion'] ?? '').toString(),
        calories: _parseCalories(j),
        categorias: (j['categorias'] is List)
            ? (j['categorias'] as List).map((e) => '$e').toList()
            : null,
        description: j['description']?.toString(),
        imgUrl: j['imgUrl']?.toString(),
      );

  static double _parseCalories(Map<String, dynamic> j) {
    final v = j['calories'] ?? j['kcal_per_portion'] ?? j['kcal'];
    if (v is num) return v.toDouble();
    if (v is String) {
      final parsed = double.tryParse(v.replaceAll(',', '.'));
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static String _slug(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+', caseSensitive: false), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

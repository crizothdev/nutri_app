/// Campos extras abaixo (categorias/description/imgUrl) **não** estão no DB,
/// mas ajudam a UI. Persistimos apenas os do schema.
class Food {
  final int? id;
  final String code;
  final String name;
  final String defaultPortion;
  final double kcalPerPortion;

  // Não persistidos (úteis para a UI quando vierem do JSON do app)
  final List<String>? categorias;
  final String? description;
  final String? imgUrl;

  const Food({
    this.id,
    required this.code,
    required this.name,
    required this.defaultPortion,
    required this.kcalPerPortion,
    this.categorias,
    this.description,
    this.imgUrl,
  });

  Food copyWith({
    int? id,
    String? code,
    String? name,
    String? defaultPortion,
    double? kcalPerPortion,
    List<String>? categorias,
    String? description,
    String? imgUrl,
  }) =>
      Food(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        defaultPortion: defaultPortion ?? this.defaultPortion,
        kcalPerPortion: kcalPerPortion ?? this.kcalPerPortion,
        categorias: categorias ?? this.categorias,
        description: description ?? this.description,
        imgUrl: imgUrl ?? this.imgUrl,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'code': code,
        'name': name,
        'default_portion': defaultPortion,
        'kcal_per_portion': kcalPerPortion,
      };

  factory Food.fromMap(Map<String, dynamic> m) => Food(
        id: m['id'] as int?,
        code: m['code'] as String,
        name: m['name'] as String,
        defaultPortion: m['default_portion'] as String,
        kcalPerPortion: (m['kcal_per_portion'] as num).toDouble(),
      );

  /// Mapper útil para o JSON de `alimentos_com_imagens.dart`
  /// Exemplo de entrada:
  /// { "nome":"Arroz branco","porcao":"100g","categorias":[...],"description":"...","imgUrl":"..." }
  /// - `code`: slug do nome
  /// - `kcal`: não vem; default 0.0 (atualize quando necessário)
  factory Food.fromAppJson(Map<String, dynamic> j) => Food(
        code: _slug(j['nome'] ?? j['name'] ?? 'food'),
        name: (j['nome'] ?? j['name'] ?? '').toString(),
        defaultPortion: (j['porcao'] ?? j['default_portion'] ?? '').toString(),
        kcalPerPortion: (j['kcal_per_portion'] is num)
            ? (j['kcal_per_portion'] as num).toDouble()
            : 0.0,
        categorias: (j['categorias'] is List)
            ? (j['categorias'] as List).map((e) => '$e').toList()
            : null,
        description: j['description']?.toString(),
        imgUrl: j['imgUrl']?.toString(),
      );

  static String _slug(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+', caseSensitive: false), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

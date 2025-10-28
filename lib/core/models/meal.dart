class Meal {
  final int? id;
  final int menuId;
  final String name;
  final int orderIndex;

  const Meal({
    this.id,
    required this.menuId,
    required this.name,
    required this.orderIndex,
  });

  Meal copyWith({int? id, int? menuId, String? name, int? orderIndex}) => Meal(
        id: id ?? this.id,
        menuId: menuId ?? this.menuId,
        name: name ?? this.name,
        orderIndex: orderIndex ?? this.orderIndex,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'menu_id': menuId,
        'name': name,
        'order_index': orderIndex,
      };

  factory Meal.fromMap(Map<String, dynamic> m) => Meal(
        id: m['id'] as int?,
        menuId: m['menu_id'] as int,
        name: m['name'] as String,
        orderIndex: (m['order_index'] as num).toInt(),
      );
}

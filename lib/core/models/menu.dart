class Menu {
  final int? id;
  final String title;
  final int? targetKcal;

  const Menu({this.id, required this.title, this.targetKcal});

  Menu copyWith({int? id, String? title, int? targetKcal}) => Menu(
        id: id ?? this.id,
        title: title ?? this.title,
        targetKcal: targetKcal ?? this.targetKcal,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'title': title,
        'target_kcal': targetKcal,
      };

  factory Menu.fromMap(Map<String, dynamic> m) => Menu(
        id: m['id'] as int?,
        title: m['title'] as String,
        targetKcal: m['target_kcal'] as int?,
      );
}

class Client {
  final int? id;
  final int userId;
  final String name;
  final String? email;
  final String? notes;

  final String phone;
  final String weight;
  final String height;

  const Client({
    this.id,
    this.userId = 1,
    required this.name,
    this.email,
    this.notes,
    required this.phone,
    required this.weight,
    required this.height,
  });

  Client copyWith(
          {int? id, int? userId, String? name, String? email, String? notes}) =>
      Client(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        email: email ?? this.email,
        notes: notes ?? this.notes,
        phone: phone ?? this.phone,
        weight: weight ?? this.weight,
        height: height ?? this.height,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'name': name,
        'email': email,
        'notes': notes,
        'phone': phone,
        'weight': weight,
        'height': height,
      };

  factory Client.fromMap(Map<String, dynamic> m) => Client(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        name: m['name'] as String,
        email: m['email'] as String?,
        notes: m['notes'] as String?,
        phone: m['phone'] as String,
        weight: m['weight'] as String,
        height: m['height'] as String,
      );
}

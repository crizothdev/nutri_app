class Client {
  final int? id;
  final int userId;
  final String name;
  final String? email;
  final String? notes;

  const Client({
    this.id,
    required this.userId,
    required this.name,
    this.email,
    this.notes,
  });

  Client copyWith(
          {int? id, int? userId, String? name, String? email, String? notes}) =>
      Client(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        email: email ?? this.email,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'name': name,
        'email': email,
        'notes': notes,
      };

  factory Client.fromMap(Map<String, dynamic> m) => Client(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        name: m['name'] as String,
        email: m['email'] as String?,
        notes: m['notes'] as String?,
      );
}

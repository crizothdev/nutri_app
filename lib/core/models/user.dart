class User {
  final int? id;
  final String? name;
  final String? username;
  final String password;
  final String? email;
  final String? phone;
  final String? document;

  const User({
    this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.email,
    required this.phone,
    required this.document,
  });

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? phone,
    String? document,
    String? name,
  }) =>
      User(
        name: name,
        email: email,
        phone: phone,
        document: document,
        id: id ?? this.id,
        username: username ?? this.username,
        password: password ?? this.password,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'username': username,
        'password': password,
        'email': email,
        'phone': phone,
        'document': document,
        'name': name,
      };

  factory User.fromMap(Map<String, dynamic> m) => User(
        id: m['id'] as int?,
        username: m['username'] as String,
        password: m['password'] as String,
        email: m['email'] as String?,
        phone: m['phone'] as String?,
        document: m['document'] as String?,
        name: m['name'] as String,
      );
}

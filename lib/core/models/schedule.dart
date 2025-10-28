class Schedule {
  final int? id;
  final int clientId;
  final String dateIso; // yyyy-MM-dd
  final String title;
  final String? description;

  const Schedule({
    this.id,
    required this.clientId,
    required this.dateIso,
    required this.title,
    this.description,
  });

  Schedule copyWith({
    int? id,
    int? clientId,
    String? dateIso,
    String? title,
    String? description,
  }) =>
      Schedule(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        dateIso: dateIso ?? this.dateIso,
        title: title ?? this.title,
        description: description ?? this.description,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'client_id': clientId,
        'date_iso': dateIso,
        'title': title,
        'description': description,
      };

  factory Schedule.fromMap(Map<String, dynamic> m) => Schedule(
        id: m['id'] as int?,
        clientId: m['client_id'] as int,
        dateIso: m['date_iso'] as String,
        title: m['title'] as String,
        description: m['description'] as String?,
      );
}

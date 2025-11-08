dynamic normalizeQueryResult(dynamic result) {
  if (result is List) {
    // Lista de QueryRow → List<Map<String, dynamic>>
    return result.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  if (result is Map) {
    // Um único QueryRow → Map<String, dynamic>
    return Map<String, dynamic>.from(result);
  }

  if (result != null && result is Object) {
    try {
      return Map<String, dynamic>.from(result as Map);
    } catch (_) {}
  }

  throw Exception("Formato de resultado inesperado: $result");
}

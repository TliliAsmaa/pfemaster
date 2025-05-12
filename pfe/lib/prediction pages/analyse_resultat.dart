class AnalyseResult {
  final String identifiant;
  final double value;
  final String measurement;
  final String interpretation;

  AnalyseResult({
    required this.identifiant,
    required this.value,
    required this.measurement,
    required this.interpretation,
  });

  // 👇 La méthode statique pour convertir en double en toute sécurité
  static double toDoubleSafe(dynamic value) {
    if (value == null)
      return 0.0; // 👈 ici on met 0.0 si c’est nul, sinon tu peux changer si tu veux null + required
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory AnalyseResult.fromJson(Map<String, dynamic> json) {
    return AnalyseResult(
      identifiant: json['identifiant'] ?? '',
      value: toDoubleSafe(json['value']),
      measurement: json['measurement'] ?? '',
      interpretation: json['interpretation'] ?? '',
    );
  }
}

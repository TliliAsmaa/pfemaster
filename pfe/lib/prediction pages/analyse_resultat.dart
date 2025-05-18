class AnalyseResult {
  final String identifiant;
  final double value;
  final String measurement;
  final String interpretation;
  final String reference;

  AnalyseResult({
    required this.identifiant,
    required this.value,
    required this.measurement,
    required this.interpretation,
    required this.reference,
  });

  static double toDoubleSafe(dynamic value) {
    if (value == null) return 0.0;
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
      reference: json['reference'] ?? '',
    );
  }

  // 👇 Extraction min depuis reference (getter)
  double? get min {
    final regex = RegExp(
      r'(\d+\.?\d*)\s*[-à]\s*(\d+\.?\d*)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(reference);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  // 👇 Extraction max depuis reference (getter)
  double? get max {
    final regex = RegExp(
      r'(\d+\.?\d*)\s*[-à]\s*(\d+\.?\d*)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(reference);
    if (match != null) {
      return double.tryParse(match.group(2)!);
    }
    return null;
  }
}

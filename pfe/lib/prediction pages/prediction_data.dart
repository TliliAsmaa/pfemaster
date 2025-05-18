class PredictionData {
  final double? ejectionFraction;
  final double? serumCreatinine;
  final int? age;
  final int? anaemia;
  final double? creatininePhosphokinase;
  final int? diabetes;
  final int? highBloodPressure;
  final int? platelets;
  final double? serumSodium;
  final int? sex;
  final int? smoking;
  final int? time;

  PredictionData({
    this.ejectionFraction,
    this.serumCreatinine,
    this.age,
    this.anaemia,
    this.creatininePhosphokinase,
    this.diabetes,
    this.highBloodPressure,
    this.platelets,
    this.serumSodium,
    this.sex,
    this.smoking,
    this.time,
  });

  // 👇 AJOUTE static ici :
  static double? toDoubleSafe(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? toIntSafe(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  
  factory PredictionData.fromJson(Map<String, dynamic> json) {
    return PredictionData(
      ejectionFraction: toDoubleSafe(json['ejection_fraction']),
      serumCreatinine: toDoubleSafe(json['serum_creatinine']),
      age: toIntSafe(json['age']),
      anaemia: toIntSafe(json['anaemia']),
      creatininePhosphokinase: toDoubleSafe(json['creatinine_phosphokinase']),
      diabetes: toIntSafe(json['diabetes']),
      highBloodPressure: toIntSafe(json['high_blood_pressure']),
      platelets: toIntSafe(json['platelets']),
      serumSodium: toDoubleSafe(json['serum_sodium']),
      sex: toIntSafe(json['sex']),
      smoking: toIntSafe(json['smoking']),
      time: toIntSafe(json['time']),
    );
  }
}

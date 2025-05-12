import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'analyse_resultat.dart';
import 'prediction_data.dart';

class ResultatsPage extends StatelessWidget {
  final List<AnalyseResult> resultats;
  final List<PredictionData> resultats2;
  const ResultatsPage({
    Key? key,
    required this.resultats,
    required this.resultats2,
  }) : super(key: key);

  void _sauvegarderTout(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Résultats sauvegardés')));
  }

  void afficherPredictionData() {
    for (var p in resultats2) {
      print('--- PredictionData ---');
      print('Age : ${p.age}');
      print('Anaemia : ${p.anaemia}');
      print('Créatinine Phosphokinase : ${p.creatininePhosphokinase}');
      print('Diabète : ${p.diabetes}');
      print('Fraction d\'éjection : ${p.ejectionFraction}');
      print('Hypertension : ${p.highBloodPressure}');
      print('Plaquettes : ${p.platelets}');
      print('Créatinine sérique : ${p.serumCreatinine}');
      print('Sodium sérique : ${p.serumSodium}');
      print('Sexe : ${p.sex}');
      print('Fumeur : ${p.smoking}');
      print('Temps : ${p.time}');
      print('-----------------------');
    }
  }

  Future<void> _fairePrediction(BuildContext context) async {
    // Vérification que 'ejectionFraction' et 'serumCreatinine' ne sont pas nuls
    if (resultats2[0].ejectionFraction == null ||
        resultats2[0].serumCreatinine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erreur : Les valeurs de la fraction d\'éjection et de la créatinine sérique sont requises.',
          ),
        ),
      );
      return; // Arrêter la prédiction si les valeurs sont manquantes
    }
    // Préparation des données de prédiction à partir des résultats
    final data = {
      'age':
          resultats2[0].age ??
          0, // Adapte ceci en fonction des données disponibles
      'anaemia': resultats2[0].anaemia ?? 0,
      'creatinine_phosphokinase': resultats2[0].creatininePhosphokinase ?? 0.0,
      'diabetes': resultats2[0].diabetes ?? 0,
      'ejection_fraction': resultats2[0].ejectionFraction ?? 0.0,
      'high_blood_pressure': resultats2[0].highBloodPressure ?? 0,
      'platelets': resultats2[0].platelets ?? 0,
      'serum_creatinine': resultats2[0].serumCreatinine ?? 0.0,
      'serum_sodium': resultats2[0].serumSodium ?? 0.0,
      'sex': resultats2[0].sex ?? 0,
      'smoking': resultats2[0].smoking ?? 0,
      'time': resultats2[0].time ?? 0,
    };

    await sendToFlaskAPI(data, context);
  }

  // Envoi des données à l'API Flask pour la prédiction
  Future<void> sendToFlaskAPI(
    Map<String, dynamic> formData,
    BuildContext context,
  ) async {
    try {
      Uri apiUrl = Uri.parse(
        'http://192.168.7.247:5000/predict',
      ); // Remplace par ton URL Flask si nécessaire

      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        int result = data['prediction'];

        String predictionResult =
            result == 1
                ? "⚠️ Risque élevé détecté.\nMerci de consulter un médecin."
                : "✅ Aucun risque détecté.\nContinuez à suivre un mode de vie sain.";

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(predictionResult)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la prédiction.')),
        );
      }
    } catch (e) {
      print('Erreur lors de l\'envoi à l\'API: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erreur de connexion.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Résultats d'analyses")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _sauvegarderTout(context),
        icon: const Icon(Icons.save),
        label: const Text("sauvegarder"),
      ),
      body: ListView.builder(
        itemCount:
            resultats.length + 2, // cartes + bouton prédiction + bouton menu
        itemBuilder: (context, index) {
          if (index < resultats.length) {
            final r = resultats[index];
            Color color;
            String interpretationText;

            switch (r.interpretation) {
              case 'normal':
                color = Colors.yellow;
                interpretationText = "Le résultat est au rendez-vous";
                break;
              case 'bad':
                color = Colors.red;
                interpretationText =
                    "Le résultat est extrêmement au-dessus de la normale";
                break;
              default:
                color = Colors.grey;
                interpretationText = "Interprétation inconnue";
            }

            return Card(
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(backgroundColor: color, radius: 10),
                        const SizedBox(width: 10),
                        Text(
                          r.identifiant,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Résultat'),
                        Text('Valeurs de référence'),
                        Text('Unité'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${r.value}'),
                        const Text('6.0 - 11.0'), // À adapter si nécessaire
                        Text(r.measurement),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      interpretationText,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          } else if (index == resultats.length) {
            // Bouton de prédiction
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: ElevatedButton(
                onPressed: () {
                  afficherPredictionData(); // 👈 Ajout pour debug console
                  _fairePrediction(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("FAIRE PRÉDICTION"),
              ),
            );
          } else {
            // Dernier bouton : retour au menu
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("RETOUR AU MENU"),
              ),
            );
          }
        },
      ),
    );
  }
}

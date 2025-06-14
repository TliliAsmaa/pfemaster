import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  // Fonction pour formater la date
  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute}";
  }
void _showAnalysisDetails(BuildContext context, String details) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Column(
          children: [
            Text(
              "Détails de l'Analyse",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1.8,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(details, style: TextStyle(fontSize: 16)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFFF7FBFF),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Color(0xFFF7FBFF), width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Fermer',
              style: TextStyle(
                color: Color(0xFF4A90E2),
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Fonction pour afficher les détails
void _showDetails(BuildContext context, Map<String, dynamic> predictionData) {
  String details = '''
result : ${predictionData['result']}
Date : ${_formatDate(predictionData['timestamp'])}
Âge : ${predictionData['age']}
Sexe : ${predictionData['sex'] == 1 ? 'Homme' : 'Femme'}
Anémie : ${predictionData['anaemia'] == 1 ? 'Oui' : 'Non'}
Diabète : ${predictionData['diabetes'] == 1 ? 'Oui' : 'Non'}
Hypertension : ${predictionData['high_blood_pressure'] == 1 ? 'Oui' : 'Non'}
Fumeur : ${predictionData['smoking'] == 1 ? 'Oui' : 'Non'}
Créatinine phosphokinase : ${predictionData['creatinine_phosphokinase']}
Fraction d’éjection : ${predictionData['ejection_fraction']}%
Plaquettes : ${predictionData['platelets']}
Créatinine sérique : ${predictionData['serum_creatinine']}
Sodium sérique : ${predictionData['serum_sodium']}
Durée de suivi (jours) : ${predictionData['time']}
''';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Text(
                "Détails de la Prédiction",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 1.8,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(details, style: TextStyle(fontSize: 16)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFF7FBFF),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Color(0xFFF7FBFF), width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Fermer',
                style: TextStyle(
                  color: Color(0xFF4A90E2),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

    
  

  Widget _buildPredictionHistory() {
    if (userId == null) return Center(child: Text("Utilisateur non connecté"));

    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('users')
              .doc(userId)
              .collection('predictions')
              .orderBy('timestamp', descending: false)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final predictions = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: predictions.length,
          itemBuilder: (context, index) {
            final prediction = predictions[index];
            final result = prediction['result'];
            final timestamp = prediction['timestamp'];

            final formattedDate = _formatDate(timestamp);

            Color resultColor;
            IconData resultIcon;
            if (result == 'Risque élevé') {
              resultColor = Colors.red;
              resultIcon = Icons.error;
            } else  {
              resultColor = Colors.green;
              resultIcon = Icons.check_circle;
            } 

            return Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      "Prédiction ${index + 1}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Résultat : $result',
                      style: TextStyle(fontSize: 16, color: resultColor),
                    ),
                    trailing: Icon(resultIcon, color: resultColor),
                    onTap: () {
                       _showDetails(context, prediction.data() as Map<String, dynamic>);
                    },
                  ),
                  Divider(color: Colors.grey.shade300, thickness: 1.5),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Date : $formattedDate',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnalysisHistory() {
    if (userId == null) return Center(child: Text("Utilisateur non connecté"));

    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('users')
              .doc(userId)
              .collection('analyses')
              .orderBy('timestamp', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final analyses = snapshot.data!.docs;

        if (analyses.isEmpty)
          return Center(child: Text("Aucune analyse trouvée"));

        return ListView(
          padding: EdgeInsets.all(16),
          children:
              analyses.map((analyseDoc) {
                final Timestamp timestamp = analyseDoc['timestamp'];
                final formattedDate = _formatDate(timestamp);

                // Pour chaque analyse, on va charger ses résultats (sous-collection 'resultats')
                return FutureBuilder<QuerySnapshot>(
                  future:
                      _firestore
                          .collection('users')
                          .doc(userId)
                          .collection('analyses')
                          .doc(analyseDoc.id)
                          .collection('resultats')
                          .get(),
                  builder: (context, snapshotResultats) {
                    if (!snapshotResultats.hasData)
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(child: CircularProgressIndicator()),
                      );

                    final resultats = snapshotResultats.data!.docs;

                    return Card(
                      color:Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: ExpansionTile(
                        title: Text(
                          "Analyse du $formattedDate",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children:
                            resultats.map((resultatDoc) {
                              final identifiant = resultatDoc['identifiant'];
                              final valeur = resultatDoc['valeur'].toString();
                              final unite = resultatDoc['unite'];
                              final interpretation =
                                  resultatDoc['interpretation'];

                              Color interpretationColor;
                              if (interpretation.toLowerCase() == 'normal') {
                                interpretationColor = Colors.green;
                              } else if (interpretation.toLowerCase() ==
                                      'élevé' ||
                                  interpretation.toLowerCase() == 'haut') {
                                interpretationColor = Colors.red;
                              } else {
                                interpretationColor = Colors.orange;
                              }

                              return ListTile(
                                leading: Icon(
                                  Icons.bloodtype,
                                  color: interpretationColor,
                                ),
                                title: Text(
                                  identifiant,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Valeur : $valeur $unite'),
                                    Text(
                                      'Interprétation : $interpretation',
                                      style: TextStyle(
                                        color: interpretationColor,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _showAnalysisDetails(
                                    context,
                                    "Test : $identifiant\nValeur : $valeur $unite\nInterprétation : $interpretation\nDate : $formattedDate",
                                  );
                                },
                              );
                            }).toList(),
                      ),
                    );
                  },
                );
              }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      backgroundColor: Color(0xFFF7FBFF),
      appBar: AppBar(
        title: Text(
          'Historique',
          style: TextStyle(color: Colors.black), // Titre en noir
        ),
        backgroundColor: Colors.white,
        bottom: TabBar(
          labelColor: Colors.blue, // Couleur des icônes et textes sélectionnés
          unselectedLabelColor: Colors.grey, // Couleur des icônes et textes non sélectionnés
          indicatorColor: Colors.blue, // Couleur de la ligne sous l'onglet actif
          tabs: [
            Tab(text: "Prédictions", icon: Icon(Icons.analytics)),
            Tab(text: "Analyses", icon: Icon(Icons.medical_services)),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.black), // Pour les icônes dans AppBar
      ),
      body: TabBarView(
        children: [_buildPredictionHistory(), _buildAnalysisHistory()],
      ),
    ),
  );
}
}
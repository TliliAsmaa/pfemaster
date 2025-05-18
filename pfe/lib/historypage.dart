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

  // Fonction pour afficher les détails
  void _showDetails(BuildContext context, String details) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Détails"),
            content: Text(details),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Fermer"),
              ),
            ],
          ),
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
              .orderBy('timestamp', descending: true)
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
            } else if (result == 'Normal') {
              resultColor = Colors.green;
              resultIcon = Icons.check_circle;
            } else {
              resultColor = Colors.orange;
              resultIcon = Icons.warning;
            }

            return Card(
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
                      _showDetails(
                        context,
                        "Détails supplémentaires à venir...",
                      );
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
                                  _showDetails(
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
        appBar: AppBar(
          title: Text('Historique'),
          backgroundColor: Color(0xFF5C6BC0),
          bottom: TabBar(
            tabs: [
              Tab(text: "Prédictions", icon: Icon(Icons.analytics)),
              Tab(text: "Analyses", icon: Icon(Icons.medical_services)),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildPredictionHistory(), _buildAnalysisHistory()],
        ),
      ),
    );
  }
}

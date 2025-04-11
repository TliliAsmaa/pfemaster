import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _historyStream;
  String? userId; // Variable pour stocker l'UID de l'utilisateur connecté

  @override
  void initState() {
    super.initState();
    // On récupère l'ID de l'utilisateur connecté, ici on suppose qu'il est déjà authentifié
    userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      // Récupérer les prédictions de l'utilisateur spécifique
      _historyStream = _firestore
          .collection('users')
          .doc(userId)
          .collection('predictions')
          .snapshots();
    }
  }

  // Fonction pour afficher les détails d'une prédiction
  void _showDetails(BuildContext context, String details) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Détails de la Prédiction"),
          content: Text(details),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour formater la date
  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des Prédictions'),
        backgroundColor: Color(0xFF5C6BC0), // Couleur d'AppBar modernisée
      ),
      body: userId == null
          ? Center(child: Text("Utilisateur non connecté"))
          : StreamBuilder<QuerySnapshot>(
              stream: _historyStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final predictions = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = predictions[index];
                    final result = prediction['result'];
                    final timestamp = prediction['timestamp'];
                    final uid = prediction['uid'];

                    // Formater la date
                    final formattedDate = _formatDate(timestamp);

                    // Déterminer la couleur et l'icône selon le résultat
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
                              "prédiction $index",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              'Résultat : $result',
                              style: TextStyle(
                                fontSize: 16,
                                color: resultColor,
                              ),
                            ),
                            trailing: Icon(
                              resultIcon,
                              color: resultColor,
                            ),
                            onTap: () {
                              // Afficher les détails de la prédiction ici
                              _showDetails(context, "Détails supplémentaires à venir...");
                            },
                          ),
                          Divider(
                            color: Colors.grey.shade300, // Ligne de séparation entre les infos
                            thickness: 1.5,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.grey),
                                SizedBox(width: 8),
                                Text(
                                  'Date : $formattedDate',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.grey.shade300, // Ligne de séparation supplémentaire
                            thickness: 1.5,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}


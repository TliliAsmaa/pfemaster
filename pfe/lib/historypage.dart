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
    print("User ID: $userId");
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
  void _showDetails(BuildContext context, Map<String, dynamic> predictionData) {
  String details = '''
Âge : ${predictionData['age']}
Sexe : ${predictionData['sex']== 1 ? 'Homme' : 'Femme'}
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
        
        title: Container(
          child: Column(
            children: [
              Text("Détails de la Prédiction" ,
               style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  letterSpacing: 1.2 // Couleur de texte modernisée
                
               ),),
              Divider(
                            color: Colors.grey, // Ligne de séparation supplémentaire
                            thickness: 1.8,
                          ),
            ],
          ),
           
          ),
       
        content: SingleChildScrollView(
          child: Text(details, style: TextStyle(fontSize: 16)),
        ),
        actions: [
          TextButton(
            
            style: TextButton.styleFrom(
              
              backgroundColor: Color(0xFFF7FBFF),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Color(0xFFF7FBFF), width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer',style: TextStyle(color: Color(0xFF4A90E2),fontSize: 16),),
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
      backgroundColor:  Color(0xFFF7FBFF),
      appBar: AppBar(
      backgroundColor:  Color(0xFFF7FBFF),
        // Couleur d'AppBar modernisée
      ),
      body: userId == null
          ? Center(child: Text("Utilisateur non connecté"))
          : StreamBuilder<QuerySnapshot>(
              stream: _historyStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Aucune prédiction trouvée.",style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),));
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
                              _showDetails(context, prediction.data() as Map<String, dynamic>);
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


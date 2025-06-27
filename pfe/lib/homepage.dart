import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:pfemaster/component/textformfield.dart';
import 'dart:math';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? userData;
  String? photoUrl;

  int totalPredictions = 0;
  int highRiskCount = 0;
  int lowRiskCount = 0;
  String? lastPrediction;
  String? lastPredictionAdvice;

  @override
  void initState() {
    super.initState();
    fetchUserData();
   
    fetchPredictionStats();
    // fetchLastPrediction();

    // Choisir un conseil santé aléatoire à chaque ouverture
    currentHealthTip = healthTips[Random().nextInt(healthTips.length)];
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

      setState(() {
        userData = doc;
      });
    }
  }



  Future<void> fetchPredictionStats() async {
    if (user != null) {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .collection('predictions')
              .get();

      int total = snapshot.docs.length;
      int high = 0;
      int low = 0;

      for (var doc in snapshot.docs) {
        String result = doc['result'].toString();
        if (result == 'Risque élevé') {
          high++;
        } else {
          low++;
        }
      }

      setState(() {
        totalPredictions = total;
        highRiskCount = high;
        lowRiskCount = low;
      });
    }
  }

  /*Future<void> fetchLastPrediction() async {
    if (user == null) return;

    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .collection('predictions')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final result = snapshot.docs.first['result']?.toString();

        setState(() {
          lastPrediction = result;
          print(lastPrediction);
          if (result == "Pas de risque") {
            lastPredictionAdvice = "Continuez à maintenir un mode de vie sain.";
          } else if (result == "Risque faible") {
            lastPredictionAdvice =
                "Gardez une bonne hygiène de vie et refaites un contrôle bientôt.";
          } else if (result == "Risque modéré") {
            lastPredictionAdvice =
                "Surveillez régulièrement vos symptômes et consultez un médecin si besoin.";
          } else if (result == "Risque élevé") {
            lastPredictionAdvice =
                "Consultez immédiatement un professionnel de santé.";
          } else {
            lastPredictionAdvice =
                "Restez attentif à tout changement dans votre santé.";
          }
        });
      } else {
        setState(() {
          lastPrediction = "Aucune prédiction trouvée";
          lastPredictionAdvice = null;
        });
      }
    } catch (e) {
      setState(() {
        lastPrediction = "Erreur lors de la récupération";
        lastPredictionAdvice = null;
      });
      print("Erreur lors de fetchLastPrediction : $e");
    }
  }
*/
  /*-----------------------------*/
  String currentHealthTip = "";

  List<String> healthTips = [
    "Faites au moins 30 min d'activité par jour.",
    "Buvez au moins 1,5 litre d'eau chaque jour.",
    "Privilégiez une alimentation riche en fibres.",
    "Dormez entre 7 et 8 heures par nuit.",
    "Réduisez votre consommation de sel et de sucre.",
    "Pratiquez la méditation pour réduire le stress.",
    "Faites des pauses régulières si vous travaillez assis.",
    "Faites un bilan de santé annuel.",
  ];

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String fullName = userData!['full name'] ?? 'Nom non disponible';

    return Scaffold(
      backgroundColor: Color(0xFFF7FBFF),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Bonjour, ",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
              TextSpan(
                text: "$fullName 👋",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              GoogleSignIn googleSignIn = GoogleSignIn();
              googleSignIn.disconnect();
              await FirebaseAuth.instance.signOut();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil("Login", (route) => false);
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 300,
                margin: EdgeInsets.symmetric(horizontal: 3),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Comment allez-vous \aujourd’hui ?",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Roboto',
                        fontSize: 30, 
                        fontWeight: FontWeight.w300,
                        color: Color.fromARGB(255, 23, 23, 23),
                        height: 1.8,
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                           final result = await Navigator.pushNamed(context, "formPrediction");

  if (result == true) {
    // Une nouvelle prédiction a été faite → on recharge les stats
    fetchPredictionStats();
  }
                          },
                          icon: Icon(Icons.analytics, color: Colors.white,size: 20),
                          label: Text(
                            "predict",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4A90E2),
                            minimumSize: Size(150, 50),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: StadiumBorder(),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, 'imagePrediction');
                          },
                          icon: Icon(
                            Icons.camera_alt,
                            color: Color(0xFF4A90E2),
                            size: 20,
                          ),
                          label: Text(
                            "caméra",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(150, 50),
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: StadiumBorder(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
              SizedBox(height: 18),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📈 Vos statistiques",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    IntrinsicHeight(
  child: Row(
    children: [
      for (var stat in [
        {
          'icon': Icons.analytics,
          'label': "Total Prédictions",
          'value': totalPredictions.toString(),
          'color': Colors.blueAccent
        },
        {
          'icon': Icons.warning,
          'label': "Risque élevé",
          'value': highRiskCount.toString(),
          'color': Colors.redAccent
        },
        {
          'icon': Icons.health_and_safety,
          'label': "Risque faible",
          'value': lowRiskCount.toString(),
          'color': Colors.green
        },
      ])
        Expanded(
          child: SizedBox(
            height: 140,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 6),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: _buildColoredStatCard(
                icon: stat['icon'] as IconData,
                label: stat['label'] as String,
                value: stat['value'] as String,
                color: stat['color'] as Color,
                withContainer: false,
              ),
            ),
          ),
        ),
    ],
  ),
),

                  ],
                ),
              ),

              /* Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📝 Dernière prédiction",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.from(
                              alpha: 1,
                              red: 0.341,
                              green: 0.298,
                              blue: 0.922,
                            ).withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Statut : ${lastPrediction ?? '...'}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: 12),
                            Divider(color: Colors.grey[400]),
                            SizedBox(height: 12),
                            Text(
                              "Conseil : ${lastPredictionAdvice ?? 'Consultez un spécialiste si vous ressentez des symptômes.'}",
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),*/
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "🧠 Conseils Santé",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B2B2B),
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Color(0xFFD0F4DE),
                child: ListTile(
                  leading: Icon(Icons.local_hospital, color: Colors.teal),
                  title: Text(currentHealthTip),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  "\"Un cœur en bonne santé, c’est un esprit apaisé.\" ❤️",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColoredStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool withContainer = true,
  }) {
    final cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (withContainer) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: cardContent,
      );
    } else {
      return cardContent;
    }
  }
}

  /*
            // 🟢 Dernière prédiction
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.favorite, color: Colors.redAccent),
                title: Text("Dernière prédiction : Risque faible ❤️"),
                subtitle: Text("04 Avril 2025"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // redirection vers l’historique
                },
              ),
            ),

            SizedBox(height: 20),

           

            SizedBox(height: 30),
             ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, 'imagePrediction');
      },
      icon: Icon(Icons.camera_alt),
      label: Text("Via Image"),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        backgroundColor: Colors.deepPurple.shade100,
        foregroundColor: Colors.deepPurple,
      ),),

            // 📊 Mini stats
            Text("📈 Vos statistiques", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard("Prédictions", "12"),
                _buildStatCard("Risque élevé", "2"),
                _buildStatCard("Risque faible", "10"),
              ],
            ),

            SizedBox(height: 30),

            // 🧠 Conseils Santé
            Text("🧠 Conseils Santé", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2B2B2B))),
            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Color(0xFFD0F4DE),
              child: ListTile(
                leading: Icon(Icons.local_hospital, color: Colors.teal),
                title: Text("Faites au moins 30 min d'activité par jour."),
              ),
            ),

            SizedBox(height: 20),

            // 💬 Citation
            Center(
              child: Text(
                "\"Un cœur en bonne santé, c’est un esprit apaisé.\" ❤️",
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  

  Widget _buildStatCard(String title, String count) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
*/
  

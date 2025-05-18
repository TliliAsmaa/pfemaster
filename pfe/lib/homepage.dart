import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pfemaster/component/textformfield.dart';

/*class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<DocumentSnapshot> data = [];
 String userId=FirebaseAuth.instance.currentUser!.uid;
  getData() async {
     DocumentSnapshot querySnapshot = await FirebaseFirestore.instance.collection("users").doc(userId).get();
      data.add(querySnapshot); // Add DocumentSnapshot to the list
      setState(() {
        
      });
  }
@override
void initState() {
  getData();
  super.initState();
  
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async{
              GoogleSignIn googleSignIn = GoogleSignIn();
              googleSignIn.disconnect();
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("Login", (route) => false);
            },
          ),
        ],
        title: Text('Home Page'),
      ),
      body: ListView.builder(
        itemCount: data.length,
       itemBuilder: (context, index) {
         return Card(
          child:Column(
            children: [
            
              Text("email: ${data[index]['email']}"),
              Text("age: ${data[index]['age']}"),
            ],
          ),
         );
       }
           /* FirebaseAuth.instance.currentUser!.emailVerified ? Text("welcome") 
            : MaterialButton(
              child: Text("please verify your email"),
              color:Colors.blueAccent,
              textColor: Colors.white,
              onPressed: (){
                FirebaseAuth.instance.currentUser!.sendEmailVerification().then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("verification email sent")));
                });
              },

             
              ),*/
         

        
      
         
      ),
    );
  }
}*/


//+===============================================//

/*
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  
  User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

//pour afficher les données de l'utilisateur
  Future<void> fetchUserData() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      setState(() {
        userData = doc;
      });
    }
  }

// Fonction pour envoyer les données au backend (API Flask)
 
  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF7FBFF),
       appBar: AppBar(
        backgroundColor: Color(0xFFF7FBFF),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async{
              GoogleSignIn googleSignIn = GoogleSignIn();
              googleSignIn.disconnect();
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("Login", (route) => false);
            },
          ),
        ],),
        
          body: /*Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text("Name: ${userData!['full name']}", style: TextStyle(fontSize: 18)),
              Text("Email: ${userData!['email']}", style: TextStyle(fontSize: 18)),
              Text("Date of Birth: ${userData!['birth date']}", style: TextStyle(fontSize: 18)),
              Text("Gender: ${userData!['gender']}", style: TextStyle(fontSize: 18)),
              Text("Age: ${userData!['age']}", style: TextStyle(fontSize: 18)),
            ],
          ),
        ),

        
      ),*/
      Container(
        child:Column(
          children :[
            MaterialButton(
              child: Text("get prédiction"),
              color:Colors.blueAccent,
              textColor: Colors.white,
              onPressed: (){
                Navigator.pushNamed(context, "formPrediction");
              },

             ),
             SizedBox(height: 20),
            
          ],
        ),
      )

        
        );
    
  }}*/


 

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _loadUserPhoto();
    fetchPredictionStats();
    // Choisir un conseil santé aléatoire à chaque ouverture
    currentHealthTip = healthTips[Random().nextInt(healthTips.length)];
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      setState(() {
        userData = doc;
      });
    }
  }

  Future<void> _loadUserPhoto() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          photoUrl = doc.data()!['photoUrl'];
        });
      }
    }
  }

  Future<void> fetchPredictionStats() async {
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('predictions')
        .get();

      int total = snapshot.docs.length;
      int high = 0;
      int low = 0;

      for (var doc in snapshot.docs) {
        String result = doc['result'].toString();
        if (result == 'Risque élevé' ) {
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
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String fullName = userData!['full name'] ?? 'Nom non disponible';

    return Scaffold(
      backgroundColor: Color(0xFFF7FBFF),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundImage: photoUrl != null
                ? NetworkImage(photoUrl!)
                : AssetImage("images/upload.png") as ImageProvider,
          ),
        ),
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Bonjour, ",
                style: TextStyle(color: Colors.black, fontSize: 18),
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
              Navigator.of(context).pushNamedAndRemoveUntil("Login", (route) => false);
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
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Comment allez-vous \naujourd’hui ?",
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
                          onPressed: () {
                            Navigator.pushNamed(context, "formPrediction");
                          },
                          label: Text("predict", style: TextStyle(color: Colors.white, fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4A90E2),
                            minimumSize: Size(150, 50),
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: StadiumBorder(),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, 'imagePrediction');
                          },
                          label: Text("caméra", style: TextStyle(fontSize: 16, color: Color(0xFF4A90E2))),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(150, 50),
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: StadiumBorder(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Text("📈 Vos statistiques",
                
                 textAlign: TextAlign.start,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, 
                 
                  )),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard("Prédictions", totalPredictions.toString()),
                  _buildStatCard("Risque élevé", highRiskCount.toString()),
                  _buildStatCard("Risque faible", lowRiskCount.toString()),
                ],
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text("🧠 Conseils Santé",
                 style: TextStyle(
                  fontWeight: FontWeight.bold,
                   color: Color(0xFF2B2B2B),
                   fontSize: 16,)),
              ),
              SizedBox(height: 10),
              Card(
                
                margin: EdgeInsets.symmetric(horizontal: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count) {
    return Container(
      width: 110,
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
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
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
  

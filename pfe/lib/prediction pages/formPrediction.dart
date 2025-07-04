
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pfemaster/homepage.dart';
import 'package:pfemaster/component/textformfield.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;


class Formprediction extends StatefulWidget {
  const Formprediction({super.key});

  @override
  State<Formprediction> createState() => _FormpredictionState();
}

class _FormpredictionState extends State<Formprediction> {
  
  TextEditingController creatinineController = TextEditingController();
  TextEditingController ejectionFractionController = TextEditingController();
  bool anaemia = false;
  bool diabetes = false;
  bool hypertension = false;
  bool smoking = false;
  TextEditingController plateletsController = TextEditingController();
  TextEditingController serumCreatinineController = TextEditingController();
  TextEditingController serumSodiumController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController followUpTimeController = TextEditingController();
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String predictionResult = '';
  User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? userData;
  bool isLoading = false; // Variable pour gérer l'état de chargement
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
void clearForm() {
  setState(() {
    creatinineController.clear();
    ejectionFractionController.clear();
    plateletsController.clear();
    serumCreatinineController.clear();
    serumSodiumController.clear();
    ageController.clear();
    followUpTimeController.clear();
    anaemia = false;
    diabetes = false;
    hypertension = false;
    smoking = false;
    predictionResult = '';
  });
}
// Fonction pour envoyer les données au backend (API Flask)
  void submitForm() {

    if (_formkey.currentState?.validate() ?? false) {
      // Formulaire valide, envoyer les données

        // Récupérer le sexe et le convertir en 1 ou 0
        int age = userData!['age'];
    String gender = userData!['gender'];  // récupère la valeur 'male' ou 'female'
    int genderValue = gender == 'male' ? 1 : 0;  // 1 pour homme, 0 pour femme
      final formData = {
        'age': age,
      //'age' : int.parse(ageController.text),
        'anaemia': anaemia,
        'creatinine_phosphokinase': double.parse(creatinineController.text),
        'diabetes': diabetes,
        'ejection_fraction': double.parse(ejectionFractionController.text),
        'high_blood_pressure': hypertension,
        'platelets': int.parse(plateletsController.text),
        'serum_creatinine': double.parse(serumCreatinineController.text),
        'serum_sodium': double.parse(serumSodiumController.text),
       
        'sex' : genderValue,
        'smoking': smoking,
        'time': int.parse(followUpTimeController.text),
      };

      // Appeler la fonction pour envoyer les données à l'API Flask
    sendToFlaskAPI(formData);
    }
  }



// Fonction pour envoyer les données à l'API Flask
Future<void> sendToFlaskAPI(Map<String, dynamic> formData) async {


   setState(() {
    isLoading = true;  // Début du chargement
  });

  try {
    // URL de ton API Flask (remplace par l'URL réelle de ton API)
    Uri apiUrl = Uri.parse('https://pfemaster-production.up.railway.app//predict'); // Remplace par l'URL de ton API

    // Effectuer la requête POST avec les données en format JSON
    final response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',  // Spécifie que le corps est en JSON
      },
      body: json.encode(formData),  // Convertir le formData en JSON
    );

    if (response.statusCode == 200) {
      // Si la requête est réussie
      final data = json.decode(response.body);
      print('Réponse de l\'API: ${response.body}');
      // Tu peux gérer la réponse ici, par exemple, afficher la prédiction à l'utilisateur
        setState(() {
         predictionResult = data['prediction'].toString();  
         isLoading = false;          // Récupère la prédiction de la réponse
      });
      int result = int.parse(predictionResult);
       showPredictionResult(context, result);

      print('Prédiction: ${data['prediction']}');
    } else {
      // Si la requête échoue
      print('Erreur de la requête: ${response.statusCode}');
       setState(() {
        predictionResult = 'Erreur lors de la prédiction.';
         isLoading = false;
      });
    }
  } catch (e) {
    // Gérer les erreurs de la requête HTTP
    print('Erreur lors de l\'envoi à l\'API: $e');
    setState(() {
      predictionResult = 'Erreur de connexion.';
       isLoading = false;
    });
  }
}


/*void showPredictionResult(BuildContext context, int prediction) {
  String message = prediction == 1
      ? "⚠️ Risque élevé détecté.\nMerci de consulter un médecin."
      : "✅ Aucun risque détecté.\nContinuez à suivre un mode de vie sain.";

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Résultat de la prédiction"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Fermer le dialogue
          },
          child: const Text("Fermer"),
        ),
        ElevatedButton(
          onPressed: () {
            savePredictionToFirestore(prediction); // Appel de la fonction de sauvegarde
            Navigator.pop(context);
          },
          child: const Text("Sauvegarder la prédiction"),
        ),
      ],
    ),
  );*/
  /*
  showModalBottomSheet(
    
  context: context,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Résultat de la prédiction",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text(message, style: TextStyle(fontSize: 16)),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: Text("Fermer"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: () {
                savePredictionToFirestore(prediction);
                Navigator.pop(context);
              },
              child: Text("Sauvegarder"),
            ),
          ],
        ),
      ],
    ),
  ),
);}

*/


void showPredictionResult(BuildContext context, int prediction) {
  String message = prediction == 1
      ? "⚠️ Risque élevé détecté.\nMerci de consulter un médecin."
      : "✅ Aucun risque détecté.\nContinuez à suivre un mode de vie sain.";

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 5,
            color: prediction == 1 ? Colors.red[50] : Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Résultat de la prédiction",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: prediction == 1 ? Colors.red : Colors.green,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text("Fermer", style: TextStyle(color:Color(0xFF4A90E2)),),
                onPressed: () {Navigator.pop(context);
                clearForm();}
              ),
              ElevatedButton(
                style:ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4A90E2),
                  shape: StadiumBorder(),
                ),
                onPressed: () {
                  savePredictionToFirestore(prediction);
                  Navigator.pop(context);
                  clearForm();
                },
                child: Text("Sauvegarder",style:TextStyle(color:Colors.white)),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}




Future<void> savePredictionToFirestore(int prediction) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("Utilisateur non connecté");
    return;
  }

  try {
    String gender = userData!['gender'];  // récupère la valeur 'male' ou 'female'
    int genderValue = gender == 'male' ? 1 : 0;  // 1 pour homme, 0 pour femme
    await FirebaseFirestore.instance
        .collection('users') // Accès à la collection des utilisateurs
        .doc(user.uid)       // Document de l'utilisateur courant
        .collection('predictions')
        .add({
          'uid': user.uid,
          'result': prediction == 1 ? "Risque élevé" : "Pas de risque",
          'timestamp': FieldValue.serverTimestamp(),
          'age': userData!['age'],
          'anaemia': anaemia,
          'creatinine_phosphokinase': double.parse(creatinineController.text),
          'diabetes': diabetes,
          'ejection_fraction': double.parse(ejectionFractionController.text),
          'high_blood_pressure': hypertension,
          'platelets': int.parse(plateletsController.text),
          'serum_creatinine': double.parse(serumCreatinineController.text),
          'serum_sodium': double.parse(serumSodiumController.text),
          'sex' : genderValue,
          'smoking': smoking,
          'time': int.parse(followUpTimeController.text),
        });
       Navigator.pop(context, true);

    print("Prédiction sauvegardée avec succès");
  } catch (e) {
    print("Erreur lors de la sauvegarde : $e");
  }
}

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
         //title: Text("Prédiction avec un formulaire" ,style: TextStyle(fontSize: 19),),
        backgroundColor: Color(0xFFF7FBFF),
        /*actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async{
              GoogleSignIn googleSignIn = GoogleSignIn();
              googleSignIn.disconnect();
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("Login", (route) => false);
            },
          ),
        ],*/),
      body:

      Container(
        padding: EdgeInsets.all(25),
        child:ListView(
          children: [
            Container(
              
              margin: EdgeInsets.all(10),
              child: Form(
                
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                      
                      Container(
                          child: Column(
                            children: [
                             // espace entre les textes
                            Text(
                            'Veuillez remplir le formulaire ci-dessous pour prédire le risque de maladie cardiaque.',
                             style: TextStyle(fontSize: 20,
                             height:1.5,
                              letterSpacing: 0.9,
                             fontStyle: FontStyle.italic,
                              color: const Color.fromARGB(255, 75, 75, 75),
                              fontWeight: FontWeight.bold),
                 ),
                            ],
                          ),
                          
                        ),
                        SizedBox(height: 30),
                       /* Text("Age", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                         SizedBox(height: 10),
                        // Full Name Field
                        CustomTextFormField(
                           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                  mycontroller: ageController,
                 hinttext:  'age',
                 // keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer age';
                    }
                    return null;
                  },
                ),*/
                SizedBox(height: 15),
                Text("Créatinine Phosphokinase", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                         SizedBox(height: 10),
                       CustomTextFormField(
                         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                  mycontroller: creatinineController,
                 hinttext:  'Créatinine Phosphokinase (mcg/L)',
                
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer la créatinine';
                    }
                    final val = double.tryParse(value);
  if (val == null || val < 23 || val > 7861) {
    return "La valeur doit être comprise entre 23 et 7861 mcg/L";
  }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                Text("Fraction d\'éjection", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                         SizedBox(height: 10),
                // Champ Ejection Fraction
                CustomTextFormField(
                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                  mycontroller: ejectionFractionController,
                 hinttext: ( 'Fraction d\'éjection (%)'),
                 
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer la fraction d\'éjection';
                    }
                     final val = int.tryParse(value);
  if (val == null || val < 14 || val > 80) {
    return "Fraction d'éjection entre 14% et 80%";
  }
                    return null;
                  },
                ),
                SizedBox(height: 15),
               Text("Plaquettes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                // Champ Platelets
                CustomTextFormField(
                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                  mycontroller: plateletsController,
                  hinttext: ('Plaquettes (k/mL)'),
                  
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer les plaquettes';
                    }
                     final val = double.tryParse(value);
  if (val == null || val < 25100 || val > 850000) {
    return "Valeur attendue entre 25 100 et 850 000 k/mL";
  }
                    return null;
                  },
                ),
                 SizedBox(height: 15),
                // Champs de sérum
                 Text("Sérum Créatinine", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                CustomTextFormField(
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  mycontroller: serumCreatinineController,
                 hinttext: ('Sérum Créatinine (mg/dL)'),
                 
                   
                    keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le sérum créatinine';
                    }
                     final val = double.tryParse(value);
  if (val == null || val < 0.5 || val > 9.4) {
    return "Valeur entre 0.5 et 9.4 mg/dL attendue";
  }
                    return null;
                  },
                ),
                 SizedBox(height: 15),
                Text("Sodium Sérique", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                CustomTextFormField(
                  mycontroller: serumSodiumController,
                  hinttext :('Sodium Sérique (mEq/L)'),
                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le sodium sérique';
                    }
                    final val = int.tryParse(value);
  if (val == null || val < 113 || val > 148) {
    return "Sodium entre 113 et 148 mEq/L requis";
  }
                    return null;
                  },
                ),
                 SizedBox(height: 15),
                // Champ Time (follow-up)
                Text("Temps de suivi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                CustomTextFormField(
                   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                  mycontroller: followUpTimeController,
                 hinttext : ('Temps de suivi (jour)'),
                  
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le temps de suivi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                 // Champs booléens (Anaemia, Diabetes, etc.)
                SwitchListTile(
                  title: Text('Anémie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: anaemia? Color(0xFF4A90E2) : Colors.black,)),
                  value: anaemia,
                  activeColor: Color(0xFF4A90E2),        // couleur du bouton switch (le cercle)
                  activeTrackColor: const Color.fromARGB(255, 153, 186, 215), // couleur de la piste quand activé
                  inactiveThumbColor: Colors.grey,   // couleur du bouton quand désactivé
                  inactiveTrackColor: Colors.grey[300], // piste quand désactivé
                  onChanged: (bool value) {
                    setState(() {
                      anaemia = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                SwitchListTile(
                  
                  title: Text('Diabetes', 
                         style: TextStyle(
                          fontSize: 16,
                           fontWeight: FontWeight.bold,
                           color: diabetes ? Color(0xFF4A90E2) : Colors.black, // change la couleur du texte
                           )),
                  value: diabetes,
                   activeColor: Color(0xFF4A90E2),        // couleur du bouton switch (le cercle)
                  activeTrackColor: const Color.fromARGB(255, 153, 186, 215), // couleur de la piste quand activé
                  inactiveThumbColor: Colors.grey,   // couleur du bouton quand désactivé
                  inactiveTrackColor: Colors.grey[300], // piste quand désactivé
                  onChanged: (bool value) {
                    
                    setState(() {
                      diabetes = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                SwitchListTile(
                  title: Text('Hypertension', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: hypertension ? Color(0xFF4A90E2) : Colors.black,)),
                  value: hypertension,
                  activeColor: Color(0xFF4A90E2),        // couleur du bouton switch (le cercle)
                  activeTrackColor: const Color.fromARGB(255, 153, 186, 215), // couleur de la piste quand activé
                  inactiveThumbColor: Colors.grey,   // couleur du bouton quand désactivé
                  inactiveTrackColor: Colors.grey[300], // piste quand désactivé
                  onChanged: (bool value) {
                    setState(() {
                      hypertension = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                SwitchListTile(
                  title: Text('fumeur', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: smoking ? Color(0xFF4A90E2) : Colors.black,)),
                  value: smoking,
                  activeColor: Color(0xFF4A90E2),        // couleur du bouton switch (le cercle)
                  activeTrackColor: const Color.fromARGB(255, 153, 186, 215), // couleur de la piste quand activé
                  inactiveThumbColor: Colors.grey,   // couleur du bouton quand désactivé
                  inactiveTrackColor: Colors.grey[300], // piste quand désactivé
                  onChanged: (bool value) {
                    setState(() {
                      smoking = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: submitForm,
                   
                      child: Text("predict", style: TextStyle(color: Colors.white, fontSize: 20)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4A90E2),
                               minimumSize: Size(200, 50),
                              //backgroundColor: Color.fromARGB(255, 181, 195, 219),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              
                              shape: StadiumBorder(),
                            ),
                  ),
                ),
               SizedBox(height: 20),
                  // Affichage de l'indicateur de chargement ou de la prédiction
                  if (isLoading)
                    CircularProgressIndicator(),
                 
                     ],
                )),
            ),
          ],
        ),
      ),
      

      
    );
  }
}
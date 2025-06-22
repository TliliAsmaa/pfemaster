import 'dart:convert';
import 'dart:io';
import 'package:open_file/open_file.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'analyse_resultat.dart';
import 'resultats_page.dart';
import 'prediction_data.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
class ImagePredictionPage extends StatefulWidget {
  const ImagePredictionPage({super.key});

  @override
  State<ImagePredictionPage> createState() => _ImagePredictionPageState();
}

class _ImagePredictionPageState extends State<ImagePredictionPage> {
  File? _image;
  bool _isLoading = false;

  /*------------------------- */
  String _resultat = '';
  int? _age;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      // Récupère l'utilisateur connecté
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Accès au document de l'utilisateur
        DocumentSnapshot doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;

          // Récupère l'âge et le genre directement
          int age = data['age'] ?? 0;
          String gender = data['gender'] ?? 'Inconnu';

          // ✅ Affichage dans la console
          print('Âge de l\'utilisateur : $age');
          print('Genre de l\'utilisateur : $gender');

          setState(() {
            _age = age;
            _gender = gender;
          });
        }
      } else {
        setState(() {
          _resultat = 'Aucun utilisateur connecté.';
        });
      }
    } catch (e) {
      setState(() {
        _resultat = 'Erreur lors de la récupération des infos : $e';
      });
    }
  }

  /*------------------------- */

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  


  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
  

  
  Future<void> _analyserImage() async {
    if (_image == null) return;
    setState(() {
      _isLoading = true;
    });
    print("Analyse en cours avec les infos suivantes :");
    print("Âge : $_age");
    print("Genre : $_gender");
    final uri = Uri.parse('https://pfemaster-production.up.railway.app/analyse');
    var request =
        http.MultipartRequest('POST', uri)
          /*..fields['gender'] = 'homme'
          ..fields['age'] = '30'*/
          ..fields['gender'] = _gender!
          ..fields['age'] = _age.toString()
          ..fields['smoking'] = 'oui'
          ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

    var response = await request.send();
  
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      try {
        final jsonMap = json.decode(responseBody);
        print("Réponse JSON : $jsonMap");
 // Vérification : si les deux champs sont absents ou vides, on affiche une erreur
        final isResultsEmpty = jsonMap['results'] == null || (jsonMap['results'] as List).isEmpty;
         final isDataEmpty = jsonMap['data'] == null || (jsonMap['data'] as Map).isEmpty;

        if (isResultsEmpty || isDataEmpty) {
          _showError("Aucun résultat détecté. Veuillez réessayer avec une image plus lisible.");
           setState(() {
      _isLoading = false;
       });
          return;

  }
        if (jsonMap['results'] != null && jsonMap['results'] is List) {
          final results = jsonMap['results'] as List;
          List<AnalyseResult> analyses =
              results.map((r) => AnalyseResult.fromJson(r)).toList();
          PredictionData? predictionData;
          if (jsonMap['data'] != null) {
            predictionData = PredictionData.fromJson(jsonMap['data']);
          }
          if (jsonMap['error'] != null) {
             _showError(jsonMap['error']);
              return;
}
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ResultatsPage(
                      resultats: analyses,
                      resultats2:
                          predictionData != null ? [predictionData] : [],
                    ),
              ),
            );
          }
        } else {
          _showError("Format inattendu : pas de clé 'results'.");
        }
      } catch (e) {
        _showError("Erreur de décodage JSON : $e");
      }
    } else {
      _showError("Erreur lors de l'analyse");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showError(String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 10),
          Text(
            "Erreur",
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
      content: Text(message, style: TextStyle(fontSize: 16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7FBFF),
      appBar: AppBar(
        // title: Text("Prédiction via Image"),
        backgroundColor: Color(0xFFF7FBFF),
      ),
      body: Container(
        child: ListView(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Bienvenue dans votre assistant de santé !",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4A90E2),
                        height: 1.8,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    const Text(
                      "Veuillez importer une image claire et lisible de votre test médical, et laissez notre système intelligent vous fournir une analyse rapide et fiable.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        height: 1.5,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 50,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Importer une image",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickImageFromGallery,
                                icon: Icon(Icons.folder, color: Colors.white),
                                label: Text(
                                  "Parcourir",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                onPressed: _pickImageFromCamera,
                                icon: Icon(Icons.camera_alt),
                                label: Text("Utiliser la caméra"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  side: BorderSide(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_image != null)
                      Column(
                        children: [
                          Text("Image sélectionnée :"),
                          const SizedBox(height: 10),
                          Image.file(_image!, height: 200),
                          /*-------------------------------------------*/
                          const SizedBox(height: 10),
                         
                          /*------------------------*/
                          // 👉 Tu ajoutes le bouton ici :
                          const SizedBox(height: 20),
                          _isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                onPressed: () async {
                                  if (_image != null) {
                                    await _analyserImage();
                                  }
                                },

                                child: Text("Analyser l'image"),
                              ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

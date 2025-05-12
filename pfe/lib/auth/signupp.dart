import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pfemaster/component/logoauth.dart';
import 'package:pfemaster/component/textformfield.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  
  final TextEditingController _dateController = TextEditingController();
  TextEditingController email = TextEditingController();
   TextEditingController password = TextEditingController();
    TextEditingController confirmpass = TextEditingController();
   TextEditingController username = TextEditingController();
   GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String? _selectedGender;
    CollectionReference users = FirebaseFirestore.instance.collection('users');
File? _imageFile;

 

  
  /// Méthode pour uploader la photo et récupérer son lien
  Future<String?> _uploadImage(String uid) async {
    try {
      if (_imageFile == null) return null;

      final storageRef = FirebaseStorage.instance.ref().child('user_photos/$uid.jpg');
      await storageRef.putFile(_imageFile!);

      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image : $e');
      return null;
    }
  }
 /// Méthode pour enregistrer les infos utilisateur
  Future<void> addUser(String? photoUrl) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await users.doc(uid).set({
        'uid': uid,
        'full name': username.text,
        'email': email.text,
        'birth date': _dateController.text,
        'gender': _selectedGender,
        'photoUrl': photoUrl,
        'age': DateTime.now().year - DateTime.parse(_dateController.text).year,
        'created_at': DateTime.now(),
      });

      print("User ajouté avec succès !");
    } catch (e) {
      print("Erreur lors de l'ajout de l'utilisateur : $e");
    }
  }


    
/// Méthode pour choisir une image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF7FBFF),
        
      ),
        backgroundColor: Color(0xFFF7FBFF),
        body:Container(
         
          padding: EdgeInsets.all(20),
          child:ListView(
            children: [
              Form(
                    key: formkey,
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                      LogoAuth(),
                      Container(
                        child: Text(
                          "Inscription",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                       /// PHOTO DE PROFIL
                  
                       SizedBox(height: 10),
                      // Full Name Field
                      Text("Le nom complet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      CustomTextFormField(
                       
                          hinttext: "saisir votre nom complet",
                         mycontroller : username,
                        
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "veuillez saisir votre nom complet";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      // Email Field
                      Text("Adresse email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      CustomTextFormField(
                        mycontroller: email,
                       
                          hinttext: "saisir votre adresse email",
                         
                        
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "veuillez saisir votre adresse email";
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return "veuillez saisir une adresse email valide";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      // Password Field
                      Text("Mot de passe", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      CustomTextFormField(
                        mycontroller: password,
                       
                        
                          hinttext: "saisir votre mot de passe",
                          isPassword : true,
                     
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "veuillez saisir votre mot de passe";
                          }
                          if (value.length < 6) {
                            return "Mot de passe trop court";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                        Text("Confirmer mot de passe", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        CustomTextFormField(
                          mycontroller: confirmpass,
                          isPassword: true,
                         
                            hinttext: "confirmer votre mot de passe",
                          
                          
                          validator: (value) {
                            if (value != password.text) {
                              return "mot de passe non identique";
                            }
                            return null;
                          },
                        ),
                      SizedBox(height: 10),
                      //**************** */
                      // Date of Birth Field
                      Text("Date de naissance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "choisir votre date de naissance",
                           hintStyle: TextStyle(fontSize: 16,color: Colors.grey),
                          filled: true,
                           contentPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                          fillColor: Color.fromARGB(255, 234, 241, 249),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                             final today = DateTime.now();
                             final fortyYearsAgo = DateTime(today.year - 40, today.month, today.day);
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: fortyYearsAgo,
                            firstDate: DateTime(1900),
                            lastDate: fortyYearsAgo, // Max date autorisée = 40 ans aujourd'hui
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "veuillez saisir votre date de naissance";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      // Gender Field
                      Text("sexe", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        
                        items: ["homme", "Femme"]
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(255, 234, 241, 249),
                           contentPadding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,

                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "veuiller choisir votre sexe";
                          }
                          return null;
                        },
                        
                      ),
                    
                    
                      SizedBox(height: 70),
                      // Sign Up Button
                      
                    Center(
                     
                      child: 
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: MaterialButton(
                            height: 50,
                            minWidth: 450,
                            color: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.all(Radius.circular(50)),
                            ),
                            onPressed: () async{
                             if(formkey.currentState!.validate()){
                              
                               try {
                                final credential =
                                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                email: email.text,
                                password: password.text,
                               );
                                final uid = FirebaseAuth.instance.currentUser!.uid;

                              await FirebaseAuth.instance.currentUser!.sendEmailVerification();
print("done");
                                   Navigator.of(context).push(MaterialPageRoute(
  builder: (_) => EmailVerificationScreen(
    uid: uid,
    uploadImage: _uploadImage,
    addUser: addUser,
  ),
));
                               
                             /*await  FirebaseAuth.instance.currentUser!.sendEmailVerification();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("verify your email")),
                                );
                              
                                
                               
                               Navigator.of(context).pushReplacementNamed('Login');*/
  
                              
/*ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("A verification email has been sent. Please verify your email.")),
);*/


// Lancer un timer qui vérifie l'email toutes les 3 secondes
/*Timer.periodic(Duration(seconds: 3), (timer) async {
  User? user = FirebaseAuth.instance.currentUser;
  await user?.reload(); // Rafraîchir les infos de l'utilisateur
  if (user != null && user.emailVerified) {
    timer.cancel(); // Stop le timer
  
    await addUser(); // Enregistrer les infos de l'utilisateur dans Firestore

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Email verified successfully.")),
    );

    Navigator.of(context).pushReplacementNamed('Login');
  }
});*/
                                
                              

                           } on FirebaseAuthException catch (e) {
                           if (e.code == 'weak-password') {
                              print('The password provided is too weak.');
                                               } else if (e.code == 'email-already-in-use') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Email existe déja")),
                            );
                                               print('The account already exists for that email.');
                          }else{
                            
                                // Handle sign up logic here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("inscription avec succès!")),
                                );
                          }
                          
                              
                            } catch (e) {
                            print(e);
                            }
                          
                          
                          
                              
                                 }},
                              child: Text(
                                "S'inscrire",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        
                      
                    ),
                    SizedBox(height: 25),
                      InkWell(
              onTap: (){
                Navigator.of(context).pushReplacementNamed('Login');
              },
              child: Center(
                child: Text.rich(TextSpan(
                 
                   children:[
                    TextSpan(
                      text: "vous avez déja un compte? ",
                      style: TextStyle(color: Colors.black,fontSize: 15),
                    ),
                    TextSpan(
                      text: "connectez-vous",
                      style: TextStyle(color: Colors.blueAccent,fontSize: 15,fontWeight: FontWeight.bold),
                     
                    )
                  ],
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
      );
      }
}



class EmailVerificationScreen extends StatelessWidget {
  final String uid;
  final Future<String?> Function(String uid) uploadImage;
  final Future<void> Function(String? photoUrl) addUser;

  const EmailVerificationScreen({
    super.key,
    required this.uid,
    required this.uploadImage,
    required this.addUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7FBFF),
      appBar: AppBar(title: Text("Email de vérification")),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "📧 Nous vous avons envoyé un email de vérification.\n\nVeuillez cliquer sur le lien dans votre boîte mail, puis appuyez sur le bouton ci-dessous.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              child: Text("J’ai vérifié mon email"),
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                await user?.reload();

                if (user != null && user.emailVerified) {
                  final photoUrl = await uploadImage(uid);
                  await addUser(photoUrl);
                  Navigator.of(context).pushReplacementNamed('Login');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Email non encore vérifié")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

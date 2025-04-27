/*import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  Future<void> addUser() async {
  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await users.doc(uid).set({
      'uid': uid,
      'full name': username.text,
      'email': email.text,
      'birth date': _dateController.text,
      'gender': _selectedGender,
      'age': DateTime.now().year - DateTime.parse(_dateController.text).year,
      'created_at': DateTime.now(),
    });

    print("User added successfully!");
  } catch (e) {
    print("Error adding user: $e");
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
                          "SignUp",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                       SizedBox(height: 10),
                      // Full Name Field
                      Text("Full Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      CustomTextFormField(
                       
                          hinttext: "Enter your full name",
                         mycontroller : username,
                        
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your full name";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      // Email Field
                      Text("Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      CustomTextFormField(
                        mycontroller: email,
                       
                          hinttext: "Enter your email",
                         
                        
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      // Password Field
                      Text("Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      CustomTextFormField(
                        mycontroller: password,
                       
                        
                          hinttext: "Enter your password",
                          isPassword : true,
                     
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                        Text("Confirm Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        CustomTextFormField(
                          mycontroller: confirmpass,
                          isPassword: true,
                         
                            hinttext: "Confirm your password",
                          
                          
                          validator: (value) {
                            if (value != password.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                      SizedBox(height: 10),
                      //**************** */
                      // Date of Birth Field
                      Text("Date of Birth", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: "Select your date of birth",
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
                            return "Please select your date of birth";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      // Gender Field
                      Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        
                        items: ["Male", "Female"]
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
                            return "Please select your gender";
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

                               
                             /*await  FirebaseAuth.instance.currentUser!.sendEmailVerification();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("verify your email")),
                                );
                              
                                
                               
                               Navigator.of(context).pushReplacementNamed('Login');*/
  
                               await FirebaseAuth.instance.currentUser!.sendEmailVerification();
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("A verification email has been sent. Please verify your email.")),
);

// Lancer un timer qui vérifie l'email toutes les 3 secondes
Timer.periodic(Duration(seconds: 3), (timer) async {
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
});
                                
                              

                           } on FirebaseAuthException catch (e) {
                           if (e.code == 'weak-password') {
                              print('The password provided is too weak.');
                                               } else if (e.code == 'email-already-in-use') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Email already in use")),
                            );
                                               print('The account already exists for that email.');
                          }else{
                            
                                // Handle sign up logic here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Sign Up Successful!")),
                                );
                          }
                          
                              
                            } catch (e) {
                            print(e);
                            }
                          
                          
                          
                              
                                 }},
                              child: Text(
                                "Sign Up",
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
                      text: "already have an account? ",
                      style: TextStyle(color: Colors.black,fontSize: 15),
                    ),
                    TextSpan(
                      text: "Login",
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

*/



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
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmpass = TextEditingController();
  final TextEditingController username = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  String? _selectedGender;
  File? _imageFile;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFFF7FBFF)),
      backgroundColor: Color(0xFFF7FBFF),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LogoAuth(),
                  Text("SignUp", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  /// PHOTO DE PROFIL
                  Center(
                    child: InkWell(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null
                            ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[700])
                            : null,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  /// Full Name
                  Text("Full Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  CustomTextFormField(
                    hinttext: "Enter your full name",
                    mycontroller: username,
                    validator: (value) =>
                        value == null || value.isEmpty ? "Please enter your full name" : null,
                  ),

                  SizedBox(height: 10),

                  /// Email
                  Text("Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  CustomTextFormField(
                    hinttext: "Enter your email",
                    mycontroller: email,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter your email";
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 10),

                  /// Password
                  Text("Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  CustomTextFormField(
                    hinttext: "Enter your password",
                    isPassword: true,
                    mycontroller: password,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter your password";
                      if (value.length < 6) return "Password must be at least 6 characters";
                      return null;
                    },
                  ),

                  SizedBox(height: 10),

                  /// Confirm Password
                  Text("Confirm Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  CustomTextFormField(
                    hinttext: "Confirm your password",
                    isPassword: true,
                    mycontroller: confirmpass,
                    validator: (value) =>
                        value != password.text ? "Passwords do not match" : null,
                  ),

                  SizedBox(height: 10),

                  /// Date of Birth
                  Text("Date of Birth", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Select your date of birth",
                      filled: true,
                      fillColor: Color.fromARGB(255, 234, 241, 249),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? "Please select your date of birth" : null,
                  ),

                  SizedBox(height: 10),

                  /// Gender
                  Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items: ["Male", "Female"]
                        .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedGender = value),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 234, 241, 249),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Please select your gender" : null,
                  ),

                  SizedBox(height: 70),

                  /// Sign Up Button
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: MaterialButton(
                        height: 50,
                        minWidth: 450,
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        onPressed: () async {
                          if (formkey.currentState!.validate()) {
                            try {
                              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                email: email.text,
                                password: password.text,
                              );

                              await FirebaseAuth.instance.currentUser!.sendEmailVerification();

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Verification email sent.")),
                              );

                              Timer.periodic(Duration(seconds: 3), (timer) async {
                                User? user = FirebaseAuth.instance.currentUser;
                                await user?.reload();
                                if (user != null && user.emailVerified) {
                                  timer.cancel();
                                  final photoUrl = await _uploadImage(user.uid);
                                  await addUser(photoUrl);
                                  Navigator.of(context).pushReplacementNamed('Login');
                                }
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          }
                        },
                        child: Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 18)),
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

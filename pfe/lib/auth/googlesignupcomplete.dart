

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfemaster/component/logoauth.dart';
import 'package:pfemaster/component/textformfield.dart';

class Googlesignupcomplete extends StatefulWidget {
  const Googlesignupcomplete({super.key});

  @override
  State<Googlesignupcomplete> createState() => _GooglesignupcompleteState();
}

class _GooglesignupcompleteState extends State<Googlesignupcomplete> {
  
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController username = TextEditingController();
   GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String? _selectedGender;
   

  
  Future<void> saveProfile(User user) async {
  if (!formkey.currentState!.validate()) return;

 
  // Calcul de l'âge à partir de la date de naissance
  int age = DateTime.now().year - DateTime.parse(_dateController.text).year;

 
  
    CollectionReference users = FirebaseFirestore.instance.collection('users');
  // 🔁 Redirige vers la homepage
 
    //Navigator.of(context).pop();
      // Call the user's CollectionReference to add a new user
      

      return users
           .doc(user.uid) // Utiliser l'UID de l'utilisateur pour le document
      .set({
        'uid': user.uid,
        'email': user.email,
        'full name': username.text,
        'birth date': _dateController.text,
        'gender': _selectedGender,
        'age': age,
       
        'createdAt': FieldValue.serverTimestamp(),
      })
          .then((value) {
            print("User Added");
             Navigator.of(context).pushNamedAndRemoveUntil("AuthWrapper", (route) => false);
   } )
          .catchError((error) => print("Failed to add user: $error"));
    


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
                          "complete your profile",
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
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
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
                    
                    
                      SizedBox(height: 20),
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
                            onPressed: (){
                             User user = FirebaseAuth.instance.currentUser!;
                              saveProfile(user);
                            },
                              child: Text(
                                "complete",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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





 

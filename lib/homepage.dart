import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      body: ListView(
        children: [
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
          Center(
            child: Text("Welcome to the Home Page!"),
          ),

        ],
      
         
      ),
    );
  }
}
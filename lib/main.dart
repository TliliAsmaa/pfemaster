import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pfemaster/auth/OnboardingScreen.dart';

import 'package:pfemaster/auth/login.dart';
import 'package:pfemaster/auth/signupp.dart';

import 'package:pfemaster/homepage.dart';
void main() async{
  

    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   


  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
  }

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
   FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('========================User is currently signed out!');
    } else {
      print('=======================User is signed in!');
    }
  });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      
      home:(FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.emailVerified) ? HomePage() : OnboardingScreen(), // Remplace par ta page d'accueil
      //SignUpSlider(), // Appel de la page de connexion
    
      // OnboardingScreen(), // Appel de la page HomePage

      routes: {
        'onboardingscreen': (context) => OnboardingScreen(), // Remplace par ta page d'accueil
        'homepage': (context) => HomePage(), // Remplace par ta page d'accueil
        'Login': (context) => Login(), // Remplace par ta page de connexion
        'SignUp': (context) => SignUp(), // Remplace par ta page de connexion
      },
    );
  }
}

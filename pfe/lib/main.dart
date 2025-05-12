import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pfemaster/auth/OnboardingScreen.dart';
import 'package:pfemaster/auth/googlesignupcomplete.dart';

import 'package:pfemaster/auth/login.dart';
import 'package:pfemaster/auth/signupp.dart';
import 'package:pfemaster/bottomnavbar.dart';

import 'package:pfemaster/homepage.dart';
import 'package:pfemaster/modifieprofile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:pfemaster/prediction%20pages/formPrediction.dart';
import 'package:pfemaster/prediction%20pages/imagePrediction';
void main() async{
  

    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");


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
      
      
     // home:(FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.emailVerified) ?  Bottomnavbar() : OnboardingScreen(), // Remplace par ta page d'accueil
      //SignUpSlider(), // Appel de la page de connexion
    
      // OnboardingScreen(), // Appel de la page HomePage
      home: AuthWrapper(),
      routes: {
        'AuthWrapper': (context) => AuthWrapper(), // Remplace par ta page d'accueil
        'bottomnavbar': (context) => Bottomnavbar(), // Remplace par ta page d'accueil
        'imagePrediction' :(context)=> ImagePredictionPage(),
        'formPrediction' :(context) => Formprediction(),
        'googleSignupComplete': (context) => Googlesignupcomplete(), // Remplace par ta page de connexion
        'onboardingscreen': (context) => OnboardingScreen(), // Remplace par ta page d'accueil
        'homepage': (context) => HomePage(), // Remplace par ta page d'accueil
        'Login': (context) => Login(), // Remplace par ta page de connexion
        'SignUp': (context) => SignUp(), // Remplace par ta page de connexion
        'EditProfile': (context) => EditProfile(), // Remplace par ta page de connexion
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Pendant le chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Utilisateur connecté
        if (snapshot.hasData) {
           print('=======================here navbar!');
          return Bottomnavbar();
         
        }

        // Utilisateur non connecté
        return OnboardingScreen();
      },
    );
  }
}


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pfemaster/auth/Emailveirifcationscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pfemaster/auth/OnboardingScreen.dart';
import 'package:pfemaster/auth/googlesignupcomplete.dart';

import 'package:pfemaster/auth/login.dart';
import 'package:pfemaster/auth/signupp.dart';
import 'package:pfemaster/bottomnavbar.dart';
import 'package:pfemaster/auth/signupp.dart';
import 'package:pfemaster/homepage.dart';
import 'package:pfemaster/modifieprofile.dart';


import 'package:pfemaster/prediction%20pages/formPrediction.dart';

import 'package:pfemaster/prediction%20pages/imagePrediction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // indispensable avant SharedPreferences
 await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  bool awaitingVerification = prefs.getBool('awaitingEmailVerification') ?? false;

  runApp(MyApp(awaitingVerification: awaitingVerification));
}


class MyApp extends StatefulWidget {
 final bool awaitingVerification;

  const MyApp({super.key, required this.awaitingVerification});
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
      home: AuthWrapper(awaitingVerification: widget.awaitingVerification),
      routes: {
        'AuthWrapper': (context) => AuthWrapper(), 
        'bottomnavbar': (context) => Bottomnavbar(),
        'imagePrediction' :(context)=> ImagePredictionPage(),
        'formPrediction' :(context) => Formprediction(),
        'googleSignupComplete': (context) => Googlesignupcomplete(), 
        'onboardingscreen': (context) => OnboardingScreen(), 
        'homepage': (context) => HomePage(),
        'Login': (context) => Login(), 
        'SignUp': (context) => SignUp(), 
        'EditProfile': (context) => EditProfile(), 
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final bool? awaitingVerification;

  const AuthWrapper({super.key, this.awaitingVerification});
    Future<Map<String, dynamic>> _getUserPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'awaitingVerification': prefs.getBool('awaitingEmailVerification') ?? false,
    'name': prefs.getString('name') ?? '',
    'email': prefs.getString('email') ?? '',
    'birthDate': prefs.getString('birthDate') ?? '',
    'gender': prefs.getString('gender') ?? '',
  };
}

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
    final user = snapshot.data!;
 
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserPrefs(),
      builder: (context, prefsSnapshot) {
        if (!prefsSnapshot.hasData) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final prefs = prefsSnapshot.data!;
        final awaiting = prefs['awaitingVerification'] as bool;
        final name = prefs['name'] as String;
        final email = prefs['email'] as String;
        final birthDate = prefs['birthDate'] as String;
        final gender = prefs['gender'] as String;

        if (user.emailVerified) {
          return Bottomnavbar();
        } else if (awaiting) {
          return Emailverificationscreen(
            uid: user.uid,
            name: name,
            email: email,
            birthDate: birthDate,
            gender: gender,
            addUser: () async {
              await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                'uid': user.uid,
                'full name': name,
                'email': email,
                'birth date': birthDate,
                'gender': gender,
                'age': DateTime.now().year - DateTime.parse(birthDate).year,
                'created_at': DateTime.now(),
              });

              // Nettoyage des préférences
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('awaitingEmailVerification');
              await prefs.remove('name');
              await prefs.remove('email');
              await prefs.remove('birthDate');
              await prefs.remove('gender');
            },
          );
        } else {
          return OnboardingScreen();
        }
      },
    );
  }

  // Utilisateur non connecté
  return OnboardingScreen();
},
    );
  
  }

}
/*
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

        // Utilisateur non connecté
        if (!snapshot.hasData || snapshot.data == null) {
          return OnboardingScreen();
        }

        final user = snapshot.data!;

        // Vérification que l'email est vérifié + que l'utilisateur existe dans la base de données
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userDocExists = userSnapshot.data != null && userSnapshot.data!.exists;
            final isEmailVerified = user.emailVerified;

            if (isEmailVerified && userDocExists) {
              print('=======================here navbar!');
              return Bottomnavbar();
            } else if (isEmailVerified && !userDocExists) {
              // Redirect to a profile completion page if email is verified but no Firestore document exists
              return SignUp();// Reuse the Google signup complete page or create a new one
            }

            // Sinon, on reste sur Onboarding (ou tu peux mettre une autre page si tu veux)
            return OnboardingScreen();
          },
        );
      },
    );
  }
}*/
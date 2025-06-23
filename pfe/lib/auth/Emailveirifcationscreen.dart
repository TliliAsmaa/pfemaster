
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Emailverificationscreen extends StatefulWidget {
    final String uid;
  final String name;
  final String email;
  final String birthDate;
  final String gender;
  final Future<void> Function() addUser;

  const Emailverificationscreen({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.addUser,
  });

  @override
  State<Emailverificationscreen> createState() => _EmailverificationscreenState();
}

class _EmailverificationscreenState extends State<Emailverificationscreen> {
  @override
  void initState() {
    super.initState();
    sendverifylink();
  }

  // Envoie du lien de vérification
  sendverifylink() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email de vérification envoyé')),
      );
    }
  }

  // Vérifie si l'utilisateur a bien vérifié son email
  Future<void> reloadAndCheckEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    await user?.reload();

    if (user != null && user.emailVerified) {
      await widget.addUser(); // Appel de la fonction addUser passée depuis signUp
      print('User ajouté avec succès.');
    
final prefs = await SharedPreferences.getInstance();
await prefs.remove('awaitingEmailVerification');
await prefs.remove('name');
await prefs.remove('email');
await prefs.remove('birthDate');
await prefs.remove('gender');
 // supprime le flag
Navigator.of(context).pushReplacementNamed('Login');
      Navigator.of(context).pushNamedAndRemoveUntil(
        'Login',
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email non encore vérifié")),
      );
    }
  }

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
              onPressed: () async => await reloadAndCheckEmail(),
            ),
          ],
        ),
      ),
    );
  }
}

/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String uid;
  
  final Future<void> Function() addUser;


  const EmailVerificationScreen({
    super.key,
    required this.uid,
    
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
                 User? updatedUser = FirebaseAuth.instance.currentUser;
               if (updatedUser != null && updatedUser.emailVerified) {
      await addUser(); // Fonction qui ajoute l'utilisateur à Firestore
      print('User ajouté avec succès.');
      Navigator.of(context).pushReplacementNamed('Emailverificationscreen');
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
*/
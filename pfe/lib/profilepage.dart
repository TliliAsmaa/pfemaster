import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'edit_field_page.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

      if (doc.exists) {
        setState(() {
          userData = doc.data() as Map<String, dynamic>?;
        });
       
      }
    }
  }

 

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  void navigateToEdit(String field, String currentValue) async {
    final newValue = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFieldPage(field: field, currentValue: currentValue),
      ),
    );

    if (newValue != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        field: newValue,
        if (field == 'birth date') 'age': DateTime.now().year - DateTime.parse(newValue).year
      });
      fetchUserData(); // refresh UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7FBFF),
      appBar: AppBar(
        title: Text("Mon Profil"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  
                  const SizedBox(height: 16),
                  Text(
                    userData!['full name'] ?? 'Nom inconnu',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(userData!['email'] ?? '', style: TextStyle(color: Colors.grey[600])),

                  const SizedBox(height: 24),
                  _buildEditableRow("Nom complet", "full name", userData!['full name']),
                 
                  _buildInfoRow("Âge", userData!['age'].toString()), // Non modifiable
                  _buildEditableRow("Genre", "gender", userData!['gender']),
                  _buildEditableRow("Date de naissance", "birth date", userData!['birth date']),
                
                  const SizedBox(height: 32),
                  TextButton.icon(
 onPressed: () async {
  bool? confirm = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Réinitialiser le mot de passe"),
      content: Text("Un email de réinitialisation sera envoyé à ${user?.email}. Continuer ?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Annuler")),
        TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Envoyer")),
      ],
    ),
  );

  if (confirm == true && user?.email != null) {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Email de réinitialisation envoyé.")),
    );
  }
},

  icon: Icon(Icons.lock_reset),
  label: Text("Changer le mot de passe"),
  style: TextButton.styleFrom(foregroundColor: Colors.black),
),

                  TextButton.icon(
                    onPressed: logout,
                    icon: Icon(Icons.logout),
                    label: Text("Déconnexion"),
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEditableRow(String label, String field, String value) {
    return InkWell(
      onTap: () => navigateToEdit(field, value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$label :", style: TextStyle(fontWeight: FontWeight.w600)),
            Row(
              children: [
                Text(value, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(width: 8),
                Icon(Icons.edit, size: 18, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title :", style: TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pfemaster/modifieprofile.dart';

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
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();

      if (doc.exists) {
        setState(() {
          userData = doc.data() as Map<String, dynamic>?;
        });
        fetchProfileImage();
      }
    }
  }

  Future<void> fetchProfileImage() async {
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_pics/${user!.uid}.jpg');
      final url = await ref.getDownloadURL();
      setState(() {
        profileImageUrl = url;
      });
    } catch (e) {
      // Pas de photo
      print("Pas de photo trouvée");
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login'); // Ajuste la route selon ton projet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Mon Profil"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : AssetImage('assets/avatar.png') as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData!['full name'] ?? 'Nom inconnu',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(userData!['email'] ?? '', style: TextStyle(color: Colors.grey[600])),

                  const SizedBox(height: 24),
                  _buildInfoRow("Âge", userData!['age'].toString()),
                  _buildInfoRow("Genre", userData!['gender']),
                  _buildInfoRow("Date de naissance", userData!['birth date']),

                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EditProfile()),
  );
                    },
                    icon: Icon(Icons.edit),
                    label: Text("Modifier" ,style: TextStyle(color:Colors.white),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  ),

                  const SizedBox(height: 16),
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

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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

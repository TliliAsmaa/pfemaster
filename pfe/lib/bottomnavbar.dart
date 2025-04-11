import 'package:flutter/material.dart';

import 'package:pfemaster/homepage.dart';
import 'package:pfemaster/historypage.dart';

class Bottomnavbar extends StatefulWidget {
  @override
  _bottomnavbarState createState() => _bottomnavbarState();
}

class _bottomnavbarState extends State<Bottomnavbar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    HistoryPage(), // Tu peux remplacer par une vraie page plus tard
    PlaceholderWidget(title: "Profil"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade200,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String title;

  const PlaceholderWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "$title (à venir)",
        style: TextStyle(fontSize: 22, color: Colors.grey),
      ),
    );
  }
}

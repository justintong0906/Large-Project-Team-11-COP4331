// lib/Pages/Main_Dashboard_Page.dart

import 'package:flutter/material.dart';
import 'swipe_page.dart';
import 'friends_page.dart';
import 'profile_page.dart';

class MainDashboardPage extends StatefulWidget {
  final Map<String, dynamic> userData; // Ensure this is named userData
  const MainDashboardPage({super.key, required this.userData});

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  int _selectedIndex = 0;

  // Use 'late' to initialize this in initState
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // CRITICAL FIX: Ensure you are passing 'userData' to all children
    // and that the children (SwipePage, etc.) accept 'userData'
    _widgetOptions = <Widget>[
      SwipePage(currentUser: widget.userData), // Check SwipePage definition!
      FriendsPage(userData: widget.userData), // Check FriendsPage definition!
      ProfilePage(userData: widget.userData), // Check ProfilePage definition!
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Safety check to prevent index out of bounds
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.swipe), label: 'Swipe'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellow[700],
        onTap: _onItemTapped,
      ),
    );
  }
}

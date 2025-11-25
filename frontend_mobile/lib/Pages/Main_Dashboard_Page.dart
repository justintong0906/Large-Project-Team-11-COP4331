// lib/Pages/main_dashboard_page.dart

import 'package:flutter/material.dart';
import 'swipe_page.dart';
import 'friends_page.dart';
import 'profile_page.dart';

class MainDashboardPage extends StatefulWidget {
  // 1. Add constructor to accept user data
  final Map<String, dynamic> userData;
  const MainDashboardPage({super.key, required this.userData});

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  int _selectedIndex = 0;

  // 2. Use a 'late' initializer for the pages list
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // 3. Initialize the pages, passing the user data to them
    _widgetOptions = <Widget>[
      SwipePage(currentUser: widget.userData),
      FriendsPage(userData: widget.userData),
      ProfilePage(userData: widget.userData),
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
        child: _widgetOptions.elementAt(
          _selectedIndex,
        ), // Display the selected page
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.swipe), label: 'Swipe'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red[700], // Color for the selected icon/label
        unselectedItemColor: Colors.grey, // Color for unselected icons/labels
        backgroundColor: Colors.white, // Background color of the bar
        type: BottomNavigationBarType.fixed, // Ensures all items are visible
        elevation: 10, // Adds a shadow to the bar
        onTap: _onItemTapped,
      ),
    );
  }
}

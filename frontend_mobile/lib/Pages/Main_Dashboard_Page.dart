import 'package:flutter/material.dart';
import 'Swipe_Page.dart';
import 'Friends_Page.dart';
import 'Profile_Page.dart';

class MainDashboardPage extends StatefulWidget {
  // We pass the full user data object here so the tabs can use it
  final Map<String, dynamic> userData;
  const MainDashboardPage({super.key, required this.userData});

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  int _selectedIndex = 0;
  // We need to initialize this list later so we can access widget.userData
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Initialize the pages here, passing the user data to each one
    _widgetOptions = <Widget>[
      SwipePage(userData: widget.userData),
      FriendsPage(userData: widget.userData),
      ProfilePage(userData: widget.userData),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This switches the body content based on the selected bottom tab
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            activeIcon: Icon(Icons.home_filled),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red[800], // Color when selected
        unselectedItemColor: Colors.grey, // Color when not selected
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed, // Ensures all labels are visible
        showUnselectedLabels: true,
        elevation: 10,
      ),
    );
  }
}

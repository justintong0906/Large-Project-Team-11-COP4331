// lib/Pages/friend_profile_page.dart

import 'package:flutter/material.dart';

class FriendProfilePage extends StatelessWidget {
  // 1. Accept the friend's data
  final Map<String, dynamic> friend;
  const FriendProfilePage({super.key, required this.friend});

  // Helper widget for info
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.red[400]),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. Extract data. Use '??' for safety.
    final String username = friend['username'] ?? 'N/A';
    final String email = friend['email'] ?? 'No email provided';
    final String phone = friend['phone'] ?? 'No phone provided';
    // TODO: You'll also want to show their quiz answers here

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(username), // Show friend's name in AppBar
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(friend['profileImageUrl'] ?? ''),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Contact Information",
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.grey),
            _buildInfoRow(context, Icons.person, "Username", username),
            _buildInfoRow(
              context,
              Icons.school, // For school email
              "School Email",
              email,
            ),
            _buildInfoRow(context, Icons.phone, "Phone Number", phone),
            // TODO: Add their quiz answers here
          ],
        ),
      ),
    );
  }
}

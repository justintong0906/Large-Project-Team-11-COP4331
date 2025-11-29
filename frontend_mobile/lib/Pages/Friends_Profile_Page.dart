// lib/Pages/friend_profile_page.dart

import 'package:flutter/material.dart';
import '../services/api_config.dart';

class FriendProfilePage extends StatelessWidget {
  final Map<String, dynamic> friend;

  const FriendProfilePage({super.key, required this.friend});

  // --- 1. DECODE BITMASK HELPER ---
  // This takes the integer (e.g., 129) and finds which bits are '1'
  List<String> _decodeBitmask(int? mask) {
    if (mask == null || mask == 0) return ["No preferences set"];

    final List<String> traits = [];

    // Maps matching your backend logic
    const Map<String, int> bitMap = {
      // Days
      'Sunday': 0, 'Monday': 1, 'Tuesday': 2, 'Wednesday': 3,
      'Thursday': 4, 'Friday': 5, 'Saturday': 6,
      // Times
      'Early Morning': 7, 'Morning': 8, 'Late Morning': 9, 'Noon': 10,
      'Afternoon': 11, 'Evening': 12, 'Night': 13,
      // Splits
      'Push Pull Legs': 14,
      'Upper Lower': 15,
      'Bro Split': 16,
      'Other': 17, // Assuming 17 based on pattern
    };

    bitMap.forEach((label, bitIndex) {
      // Check if the bit at 'bitIndex' is set to 1
      // (1 << bitIndex) creates a number with only that bit set.
      // & operator checks if that bit exists in the mask.
      if ((mask & (1 << bitIndex)) != 0) {
        traits.add(label);
      }
    });

    return traits;
  }

  // Helper widget for info rows
  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.yellow[400]),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- 2. SAFER DATA EXTRACTION ---
    // Access top-level fields
    final String username = friend['username'] ?? 'N/A';

    // Access nested 'profile' fields safely
    final Map<String, dynamic> profile = friend['profile'] ?? {};
    final String phone = profile['phone'] ?? 'No phone provided';
    final String bio = profile['bio'] ?? 'No bio available';
    final String? imageUrl = profile['photo']; // Assuming photo is in profile
    final int bitmask = friend['questionnaireBitmask'] ?? 0;

    final List<String> workoutTags = _decodeBitmask(bitmask);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(username),
        backgroundColor: Colors.yellow[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 3. SAFE IMAGE LOADING ---
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                    ? NetworkImage(imageUrl)
                    : null,
                child: (imageUrl == null || imageUrl.isEmpty)
                    ? const Icon(Icons.person, size: 60, color: Colors.white54)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // --- BIO SECTION ---
            Text(
              "About Me",
              style: TextStyle(
                color: Colors.yellow[300],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                bio,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // --- WORKOUT PREFERENCES (Decoded Bitmask) ---
            Text(
              "Workout Style",
              style: TextStyle(
                color: Colors.yellow[300],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: workoutTags
                  .map(
                    (tag) => Chip(
                      backgroundColor: Colors.yellow[900],
                      label: Text(
                        tag,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),

            // --- CONTACT INFO ---
            Text(
              "Contact Information",
              style: TextStyle(
                color: Colors.yellow[300],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.grey),
            _buildInfoRow(Icons.person, "Username", username),
            _buildInfoRow(Icons.phone, "Phone Number", phone),
          ],
        ),
      ),
    );
  }
}

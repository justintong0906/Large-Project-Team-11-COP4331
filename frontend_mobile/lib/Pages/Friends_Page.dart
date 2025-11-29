import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // Required for Uint8List
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/api_config.dart';
import 'Friends_Profile_Page.dart';

class FriendsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const FriendsPage({super.key, required this.userData});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<dynamic> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    // 1. Get User ID
    final String userId = widget.userData['_id'] ?? widget.userData['id'] ?? '';

    if (userId.isEmpty) {
      print("Error: User ID is missing in FriendsPage");
      setState(() => _isLoading = false);
      return;
    }

    // 2. Use the correct API URL
    final String apiUrl = '${ApiConfig.baseUrl}/api/users/$userId';

    try {
      // 3. Send Token in Headers
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.userData['token']}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract friends list
        final List<dynamic> friendsList = data['friends'] ?? [];

        if (mounted) {
          setState(() {
            _matches = friendsList;
            _isLoading = false;
          });
        }
      } else {
        print("Friends API Error: ${response.statusCode}");
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching matches: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper: Safe Image Provider
  ImageProvider? _safeImageProvider(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      if (base64String.startsWith('http')) return NetworkImage(base64String);

      String cleanString = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      cleanString = cleanString.replaceAll(RegExp(r'\s+'), '');

      final Uint8List bytes = base64Decode(
        cleanString,
      ); // Fixed: Removed java.util
      if (bytes.isEmpty) return null;

      return MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Matches"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.yellow[800],
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.yellow[800]))
          : _matches.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];

                // Safe Data Extraction
                final profileData = match['profile'] ?? {};
                final String? photoUrl = profileData['photo'];
                final String username = match['username'] ?? 'User';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FriendProfilePage(friend: match),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.yellow[100],
                      backgroundImage: _safeImageProvider(photoUrl),
                      child: _safeImageProvider(photoUrl) == null
                          ? Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: Colors.yellow[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      profileData['bio'] ?? "No bio available",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text(
            "No matches yet.",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Go to the Swipe page to find buddies!",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

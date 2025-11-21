import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  // --- API Call: Get Matches ---
  Future<void> _fetchMatches() async {
    final String apiUrl =
        '${dotenv.env['API_BASE_URL']}/api/matches/${widget.userData['_id']}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _matches = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        // Handle error
        setState(() => _isLoading = false);
      }
    } catch (e) {
      // Handle connection error
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Matches"),
        backgroundColor: Colors.red[800],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
              ? const Center(
                  child: Text("No matches yet. Keep swiping!",
                      style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.builder(
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    final match = _matches[index];
                    // The match object contains the *other* user's data
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red[100],
                        child: Text(
                          match['username'][0].toUpperCase(),
                          style: TextStyle(color: Colors.red[800]),
                        ),
                      ),
                      title: Text(match['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Matched on ${match['matchedAt'] ?? ''}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Chat feature coming soon!')));
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
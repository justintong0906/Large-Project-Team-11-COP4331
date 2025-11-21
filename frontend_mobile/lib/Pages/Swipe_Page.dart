import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:swipable_stack/swipable_stack.dart';
import '../Styled accessories/styled_header_text.dart';

class SwipePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const SwipePage({super.key, required this.userData});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final _controller = SwipableStackController();
  List<dynamic> _potentialMatches = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPotentialMatches();
  }

  // --- API Call: Get Users to Swipe On ---
  Future<void> _fetchPotentialMatches() async {
    final String apiUrl = '${dotenv.env['API_BASE_URL']}/api/users/potential-matches/${widget.userData['_id']}';
    
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _potentialMatches = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
       setState(() {
          _hasError = true;
          _isLoading = false;
        });
    }
  }

  // --- API Call: Handle Swipe ---
  Future<void> _handleSwipe(String targetUserId, SwipeDirection direction) async {
    final String apiUrl = '${dotenv.env['API_BASE_URL']}/api/matches/swipe';
    final String swipeDirection = direction == SwipeDirection.right ? 'right' : 'left';

    try {
      await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'swiperId': widget.userData['_id'],
          'targetId': targetUserId,
          'direction': swipeDirection,
        }),
      );
      // You could check for a match response here and show a dialog
    } catch (e) {
      print('Error sending swipe: $e');
      // Handle error silently or show a snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return const Center(child: Text('Error loading users. Tap to retry.'));
    }
    if (_potentialMatches.isEmpty) {
      return const Center(child: Text('No more users to show! Come back later.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Discover"),
        backgroundColor: Colors.red[800],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SwipableStack(
                controller: _controller,
                itemCount: _potentialMatches.length,
                onSwipeCompleted: (index, direction) {
                  final targetUser = _potentialMatches[index];
                  _handleSwipe(targetUser['_id'], direction);
                },
                builder: (context, properties) {
                  final user = _potentialMatches[properties.index];
                  return _buildUserCard(user);
                },
              ),
            ),
            const SizedBox(height: 20),
            // --- Swipe Buttons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSwipeButton(Icons.close, Colors.red, SwipeDirection.left),
                _buildSwipeButton(Icons.favorite, Colors.green, SwipeDirection.right),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  color: Colors.grey[300],
                ),
                child: const Icon(Icons.person, size: 100, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyledHeaderText("${user['username']}, ${user['age'] ?? 'N/A'}",
                        fontSize: 24),
                    const SizedBox(height: 10),
                    Text(
                      user['bio'] ?? 'No bio yet.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeButton(IconData icon, Color color, SwipeDirection direction) {
    return FloatingActionButton(
      heroTag: direction.toString(), // Unique tag for each button
      backgroundColor: Colors.white,
      onPressed: () => _controller.next(swipeDirection: direction),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
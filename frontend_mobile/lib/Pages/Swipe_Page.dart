import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/api_config.dart';

class SwipePage extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const SwipePage({super.key, required this.currentUser});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final SwipableStackController _controller = SwipableStackController();

  List<Map<String, dynamic>> _potentialMatches = [];
  bool _isLoading = true;
  bool _isFetchingBatch = false;

  @override
  void initState() {
    super.initState();
    _fetchBatchOfUsers();
  }

  // --- 1. HELPER: CALCULATE SCORE LOCALLY ---
  int _calculateMatchScore(int otherMask) {
    int myMask = widget.currentUser['questionnaireBitmask'] ?? 0;
    int intersection = myMask & otherMask;

    // Count how many bits are set to 1 (Popcount)
    int count = 0;
    while (intersection > 0) {
      intersection &= (intersection - 1);
      count++;
    }
    return count;
  }

  // --- 2. FETCH A BATCH (LOOP 5 TIMES) ---
  Future<void> _fetchBatchOfUsers() async {
    if (_isFetchingBatch) return; // Guard against multiple calls
    setState(() => _isFetchingBatch = true);

    if (_potentialMatches.isEmpty) {
      setState(() => _isLoading = true);
    }

    // Use ApiConfig here
    final String apiUrl = '${ApiConfig.baseUrl}/api/users/compatible';
    List<Map<String, dynamic>> newBatch = [];

    // Loop to fetch 5 users to build a "deck"
    for (int i = 0; i < 5; i++) {
      try {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${widget.currentUser['token']}',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // Check for duplicates (ID check)
          bool alreadyExists =
              _potentialMatches.any((u) => u['_id'] == data['_id']) ||
              newBatch.any((u) => u['_id'] == data['_id']);

          if (!alreadyExists) {
            // Calculate score and attach it
            int score = _calculateMatchScore(data['questionnaireBitmask'] ?? 0);
            data['localScore'] = score;
            newBatch.add(data);
          }
        } else if (response.statusCode == 404) {
          // No more users found in DB
          break;
        } else if (response.statusCode == 400) {
          // --- HANDLE INCOMPLETE PROFILE ---
          _showIncompleteProfileWarning();
          setState(() {
            _isLoading = false;
            _isFetchingBatch = false;
          });
          return; // Stop fetching completely
        }
      } catch (e) {
        print("Error fetching user: $e");
      }
    }

    // --- 3. SORT THE BATCH LOCALLY ---
    // Sort descending by score (Higher score first)
    newBatch.sort(
      (a, b) => (b['localScore'] as int).compareTo(a['localScore'] as int),
    );

    if (mounted) {
      setState(() {
        _potentialMatches.addAll(newBatch);
        _isLoading = false;
        _isFetchingBatch = false;
      });
    }
  }

  void _showIncompleteProfileWarning() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Update your Profile preferences (Days, Times, Splits) to see matches!",
        ),
        backgroundColor: Colors.red[800],
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: "OK",
          textColor: Colors.white,
          onPressed: () {
            // User can manually navigate to profile
          },
        ),
      ),
    );
  }

  // --- 4. HANDLE SWIPE ---
  Future<void> _handleSwipe(int index, SwipeDirection direction) async {
    // Pagination: If we are running low (less than 3 cards), fetch another batch
    if (_potentialMatches.length - index < 3) {
      _fetchBatchOfUsers();
    }

    if (direction == SwipeDirection.left) return;

    final matchedUser = _potentialMatches[index];
    final String targetUserId = matchedUser['_id'];

    // Use ApiConfig here as well
    final String apiUrl = '${ApiConfig.baseUrl}/api/users/match/$targetUserId';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.currentUser['token']}',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == "It's a match!") {
          _showMatchDialog(matchedUser);
        }
      }
    } catch (e) {
      print("Swipe connection error: $e");
    }
  }

  Future<void> _showMatchDialog(Map<String, dynamic> matchedUser) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("It's a Match!"),
          content: Text("You and ${matchedUser['username']} matched!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Nice!"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading && _potentialMatches.isEmpty
          ? Center(child: CircularProgressIndicator(color: Colors.red[800]))
          : _potentialMatches.isEmpty
          ? _buildNoUsersState()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SwipableStack(
                controller: _controller,
                itemCount: _potentialMatches.length,
                onSwipeCompleted: (index, direction) {
                  _handleSwipe(index, direction);
                },
                builder: (context, properties) {
                  final itemIndex = properties.index % _potentialMatches.length;
                  final user = _potentialMatches[itemIndex];

                  final int score = user['localScore'] ?? 0;
                  final profile = user['profile'] ?? {};
                  final String? photoUrl = profile['photo'];
                  final String username = user['username'] ?? 'User';
                  final String bio = profile['bio'] ?? 'No bio';

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Image
                          Positioned.fill(
                            child: (photoUrl != null && photoUrl.isNotEmpty)
                                ? Image.network(photoUrl, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      size: 100,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          ),
                          // Text Overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.9),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        username,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Display the Local Score Tag
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red[800],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          "$score Shared",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    bio,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
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
                },
              ),
            ),
    );
  }

  Widget _buildNoUsersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            "No more users found.",
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchBatchOfUsers();
            },
            child: const Text("Try Refreshing"),
          ),
        ],
      ),
    );
  }
}

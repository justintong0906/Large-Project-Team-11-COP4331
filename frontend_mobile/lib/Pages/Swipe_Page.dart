import 'package:flutter/material.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
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

  // --- Image Helper ---
  ImageProvider? _safeImageProvider(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      if (base64String.startsWith('http')) return NetworkImage(base64String);
      String cleanString = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      cleanString = cleanString.replaceAll(RegExp(r'\s+'), '');
      final Uint8List bytes = base64Decode(cleanString);
      if (bytes.isEmpty) return null;
      return MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }

  // --- Score Helper ---
  int _calculateMatchScore(int otherMask) {
    int myMask = widget.currentUser['questionnaireBitmask'] ?? 0;
    int intersection = myMask & otherMask;
    int count = 0;
    while (intersection > 0) {
      intersection &= (intersection - 1);
      count++;
    }
    return count;
  }

  // --- Fetch Users ---
  Future<void> _fetchBatchOfUsers() async {
    if (_isFetchingBatch) return;
    setState(() => _isFetchingBatch = true);

    if (_potentialMatches.isEmpty) {
      setState(() => _isLoading = true);
    }

    final String apiUrl = '${ApiConfig.baseUrl}/api/users/random-compatible';
    List<Map<String, dynamic>> newBatch = [];

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
          bool alreadyExists =
              _potentialMatches.any((u) => u['_id'] == data['_id']) ||
              newBatch.any((u) => u['_id'] == data['_id']);

          if (!alreadyExists) {
            int score = _calculateMatchScore(data['questionnaireBitmask'] ?? 0);
            data['localScore'] = score;
            newBatch.add(data);
          }
        } else if (response.statusCode == 404) {
          break;
        } else if (response.statusCode == 400) {
          _showIncompleteProfileWarning();
          setState(() {
            _isLoading = false;
            _isFetchingBatch = false;
          });
          return;
        }
      } catch (e) {
        print("Error fetching user: $e");
      }
    }

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
        backgroundColor: Colors.yellow[800],
        action: SnackBarAction(
          label: "OK",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // --- NEW: Helper to Show Notifications ---
  void _showNotification(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Remove previous
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 20, left: 50, right: 50),
      ),
    );
  }

  // --- Handle Swipe ---
  Future<void> _handleSwipe(int index, SwipeDirection direction) async {
    // 1. Pagination
    if (_potentialMatches.length - index < 3) {
      _fetchBatchOfUsers();
    }

    // 2. Handle Left Swipe (Rejected)
    if (direction == SwipeDirection.left) {
      _showNotification("Rejected", Colors.grey[700]!);
      return;
    }

    // 3. Handle Right Swipe (API Call)
    final matchedUser = _potentialMatches[index];
    final String targetUserId = matchedUser['_id'];

    // FIX: URL was incorrect in your snippet. It must be /match/:id
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
        } else {
          // Show "Friend request sent" only if it wasn't an instant match
          _showNotification("Friend request sent!", Colors.green[600]!);
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
          ? Center(child: CircularProgressIndicator(color: Colors.yellow[800]))
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
                            child: _safeImageProvider(photoUrl) != null
                                ? Image(
                                    image: _safeImageProvider(photoUrl)!,
                                    fit: BoxFit.cover,
                                  )
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
                                      // Local Score Tag
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow[800],
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

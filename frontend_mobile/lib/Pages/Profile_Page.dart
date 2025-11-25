import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Login_Page.dart';
import '../services/api_config.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfilePage({super.key, required this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 1. Controllers
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _majorController;
  late TextEditingController _bioController;
  late TextEditingController _expController;

  // 2. Quiz State (Selections)
  final Set<String> _selectedDays = {};
  final Set<String> _selectedTimes = {};
  final Set<String> _selectedSplits = {};

  bool _isLoading = false;

  // --- 3. FIXED BITMAPS (MUST MATCH YOUR BACKEND EXACTLY) ---
  // Backend: DAY_BITS = { sun: 0, mon: 1, ... sat: 6 }
  final Map<String, int> _dayBits = {
    'sun': 0,
    'mon': 1,
    'tue': 2,
    'wed': 3,
    'thu': 4,
    'fri': 5,
    'sat': 6,
  };

  // Backend: TIME_BITS = { morning: 7, afternoon: 8, evening: 9 }
  final Map<String, int> _timeBits = {
    'morning': 7,
    'afternoon': 8,
    'evening': 9,
  };

  // Backend: SPLIT_BITS = { arnold: 10, ppl: 11, brosplit: 12 }
  final Map<String, int> _splitBits = {'arnold': 10, 'ppl': 11, 'brosplit': 12};

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _decodeBitmask(); // This triggers the highlighting
  }

  void _initializeFields() {
    _usernameController = TextEditingController(
      text: widget.userData['username'],
    );
    _emailController = TextEditingController(text: widget.userData['email']);

    final profile = widget.userData['profile'] as Map<String, dynamic>? ?? {};

    _ageController = TextEditingController(
      text: (profile['age'] ?? '').toString(),
    );
    _genderController = TextEditingController(text: profile['gender'] ?? '');
    _majorController = TextEditingController(text: profile['major'] ?? '');
    _bioController = TextEditingController(text: profile['bio'] ?? '');
    _expController = TextEditingController(
      text: (profile['yearsOfExperience'] ?? '').toString(),
    );
  }

  // --- 4. DECODE LOGIC (Highlights the buttons) ---
  void _decodeBitmask() {
    int mask = widget.userData['questionnaireBitmask'] ?? 0;

    // Helper to check bits
    void checkAndAdd(Map<String, int> map, Set<String> set) {
      map.forEach((key, bitIndex) {
        // If the bit at bitIndex is 1 (on), add it to our selection set
        if ((mask & (1 << bitIndex)) != 0) {
          set.add(key);
        }
      });
    }

    setState(() {
      checkAndAdd(_dayBits, _selectedDays);
      checkAndAdd(_timeBits, _selectedTimes);
      checkAndAdd(_splitBits, _selectedSplits);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _majorController.dispose();
    _bioController.dispose();
    _expController.dispose();
    super.dispose();
  }

  // --- 5. API CALL TO UPDATE ---
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    // FIX: Use ID in URL instead of '/profile' to match standard REST patterns
    final String apiUrl =
        '${ApiConfig.baseUrl}/api/users/${widget.userData['_id']}';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.userData['token']}',
        },
        body: jsonEncode({
          // 1. Send Arrays (Backend will recalculate the bitmask from these)
          'days': _selectedDays.toList(),
          'times': _selectedTimes.toList(),
          'splits': _selectedSplits.toList(),

          // 2. Send Profile Data
          'profile': {
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'age': int.tryParse(_ageController.text.trim()),
            'gender': _genderController.text.trim(),
            'major': _majorController.text.trim(),
            'bio': _bioController.text.trim(),
            'yearsOfExperience': int.tryParse(_expController.text.trim()),
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile & Preferences saved!')),
        );

        // Update Local Data so UI reflects changes immediately
        setState(() {
          // The backend returns the new bitmask, so we save it locally
          widget.userData['questionnaireBitmask'] =
              data['questionnaireBitmask'];

          if (widget.userData['profile'] == null)
            widget.userData['profile'] = {};
          widget.userData['profile']['bio'] = _bioController.text.trim();
          widget.userData['profile']['major'] = _majorController.text.trim();
          widget.userData['profile']['age'] = int.tryParse(
            _ageController.text.trim(),
          );
          widget.userData['profile']['gender'] = _genderController.text.trim();
          widget.userData['profile']['yearsOfExperience'] = int.tryParse(
            _expController.text.trim(),
          );
        });
      } else {
        print("Server Error: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not connect to the server.')),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[800],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Personal Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),

            _buildTextField(_usernameController, "Username", Icons.person),
            _buildTextField(_emailController, "Email", Icons.email),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _ageController,
                    "Age",
                    Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    _genderController,
                    "Gender",
                    Icons.transgender,
                  ),
                ),
              ],
            ),
            _buildTextField(_majorController, "Major", Icons.school),
            _buildTextField(
              _expController,
              "Years Exp",
              Icons.fitness_center,
              keyboardType: TextInputType.number,
            ),
            _buildTextField(_bioController, "Bio", Icons.article, maxLines: 3),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            const Text(
              "Matching Preferences",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Text(
              "Update these to change who you match with.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Pass the CORRECT maps here
            _buildChipSection("Days Available", _dayBits, _selectedDays),
            _buildChipSection("Preferred Times", _timeBits, _selectedTimes),
            _buildChipSection("Workout Split", _splitBits, _selectedSplits),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save All Changes',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Helper: Text Field ---
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.red[800]),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red[800]!, width: 2),
          ),
        ),
      ),
    );
  }

  // --- Helper: Chip Section ---
  Widget _buildChipSection(
    String title,
    Map<String, int> options,
    Set<String> selectedSet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.keys.map((key) {
            final isSelected = selectedSet.contains(key);
            // Simple capitalization for display
            final displayLabel = "${key[0].toUpperCase()}${key.substring(1)}";

            return FilterChip(
              label: Text(displayLabel),
              selected: isSelected,
              selectedColor: Colors.red[100],
              checkmarkColor: Colors.red[800],
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.red[800]! : Colors.grey[300]!,
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.red[900] : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedSet.add(key);
                  } else {
                    selectedSet.remove(key);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

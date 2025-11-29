import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
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
  late TextEditingController _phoneController;

  // Avatar State (Base64 String)
  String? _selectedAvatarBase64;

  // Asset Avatars (Must match pubspec.yaml)
  final List<String> _avatarAssets = [
    'assets/avatars/avatar1.jpeg',
    'assets/avatars/avatar2.jpeg',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.jpeg',
  ];

  // 2. Quiz State (Selections)
  final Set<String> _selectedDays = {};
  final Set<String> _selectedTimes = {};
  final Set<String> _selectedSplits = {};

  bool _isLoading = false;

  // --- BITMAPS ---
  final Map<String, int> _dayBits = {
    'sun': 0,
    'mon': 1,
    'tue': 2,
    'wed': 3,
    'thu': 4,
    'fri': 5,
    'sat': 6,
  };
  final Map<String, int> _timeBits = {
    'morning': 7,
    'afternoon': 8,
    'evening': 9,
  };
  final Map<String, int> _splitBits = {'arnold': 10, 'ppl': 11, 'brosplit': 12};

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _decodeBitmask();
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
    _phoneController = TextEditingController(text: profile['phone'] ?? '');

    // Load existing avatar if present
    if (profile['photo'] != null && profile['photo'].toString().isNotEmpty) {
      _selectedAvatarBase64 = profile['photo'];
    }
  }

  // --- Helper: Safe Image Decoder ---
  ImageProvider? _safeImageProvider(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }

    try {
      // Clean string
      String cleanString = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      cleanString = cleanString.replaceAll(RegExp(r'\s+'), '');

      final Uint8List bytes = base64Decode(cleanString);
      if (bytes.isEmpty) return null;

      return MemoryImage(bytes);
    } catch (e) {
      print("⚠️ Image Error: $e");
      return null;
    }
  }

  // --- Helper: Select Avatar Modal ---
  Future<void> _selectAvatar() async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Choose an Avatar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _avatarAssets.length,
                  itemBuilder: (ctx, index) {
                    return GestureDetector(
                      onTap: () async {
                        try {
                          final String assetPath = _avatarAssets[index];
                          final ByteData bytes = await rootBundle.load(
                            assetPath,
                          );
                          final Uint8List list = bytes.buffer.asUint8List();
                          // Standardize format
                          final String base64Image =
                              "data:image/png;base64,${base64Encode(list)}";

                          setState(() {
                            _selectedAvatarBase64 = base64Image;
                          });
                          if (mounted) Navigator.pop(ctx);
                        } catch (e) {
                          print("Error loading asset: $e");
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(_avatarAssets[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _decodeBitmask() {
    int mask = widget.userData['questionnaireBitmask'] ?? 0;
    void checkAndAdd(Map<String, int> map, Set<String> set) {
      map.forEach((key, bitIndex) {
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
    _phoneController.dispose();
    super.dispose();
  }

  // --- API CALL TO UPDATE ---
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    // Validate ID
    final String userId = widget.userData['_id'] ?? widget.userData['id'] ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error: Missing User ID')));
      setState(() => _isLoading = false);
      return;
    }

    final String apiUrl = '${ApiConfig.baseUrl}/api/users/$userId/quiz';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.userData['token']}',
        },
        body: jsonEncode({
          'days': _selectedDays.toList(),
          'times': _selectedTimes.toList(),
          'splits': _selectedSplits.toList(),
          'profile': {
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'age': int.tryParse(_ageController.text.trim()),
            'gender': _genderController.text.trim(),
            'major': _majorController.text.trim(),
            'bio': _bioController.text.trim(),
            'yearsOfExperience': int.tryParse(_expController.text.trim()),
            'phone': _phoneController.text.trim(),
            // Send the Base64 string directly
            if (_selectedAvatarBase64 != null) 'photo': _selectedAvatarBase64,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );

        // Update Local Data
        setState(() {
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
          widget.userData['profile']['phone'] = _phoneController.text.trim();

          if (_selectedAvatarBase64 != null) {
            widget.userData['profile']['photo'] = _selectedAvatarBase64;
          }
        });
      } else {
        try {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save failed: ${errorData['message']}')),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      print("Profile Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection Error. Check console.')),
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
        backgroundColor: Colors.yellow[800],
        centerTitle: true,
        automaticallyImplyLeading: false,
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
            // --- PHOTO SECTION ---
            Center(
              child: GestureDetector(
                onTap: _selectAvatar,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  // Use Safe Decoder
                  backgroundImage: _safeImageProvider(_selectedAvatarBase64),
                  child: _selectedAvatarBase64 == null
                      ? Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.grey[400],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Tap to change avatar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

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

            _buildTextField(
              _phoneController,
              "Phone Number",
              Icons.phone,
              keyboardType: TextInputType.phone,
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
            const SizedBox(height: 20),

            _buildChipSection("Days Available", _dayBits, _selectedDays),
            _buildChipSection("Preferred Times", _timeBits, _selectedTimes),
            _buildChipSection("Workout Split", _splitBits, _selectedSplits),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[800],
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
          prefixIcon: Icon(icon, color: Colors.yellow[800]),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

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
              color: Colors.yellow[800],
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.keys.map((key) {
            final isSelected = selectedSet.contains(key);
            final displayLabel = "${key[0].toUpperCase()}${key.substring(1)}";
            return FilterChip(
              label: Text(displayLabel),
              selected: isSelected,
              selectedColor: Colors.yellow[100],
              checkmarkColor: Colors.yellow[800],
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.yellow[800]! : Colors.grey[300]!,
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.yellow[900] : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (bool selected) {
                setState(() {
                  if (selected)
                    selectedSet.add(key);
                  else
                    selectedSet.remove(key);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'main_dashboard_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // Needed for Uint8List
import 'package:flutter/services.dart' show rootBundle; // Needed for assets
import '../services/api_config.dart';

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const QuizPage({super.key, required this.userData});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentPage = 0;
  bool _isLoading = false;

  // --- Photo & Phone State ---
  final _phoneController = TextEditingController();

  // Stores the selected image as a Base64 String
  String? _selectedAvatarBase64;

  // --- AVATAR ASSETS ---
  // IMPORTANT: Ensure these files exist in 'assets/avatars/' and are listed in pubspec.yaml
  final List<String> _avatarAssets = [
    'assets/avatars/avatar1.jpeg',
    'assets/avatars/avatar2.jpeg',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.jpeg',
  ];

  // --- Page 1-3 State (Checkboxes) ---
  List<bool> workoutDays = List.generate(7, (_) => false);
  List<bool> splitOptions = [false, false, false, false];
  List<bool> timeOptions = [false, false, false];

  // --- Page 4-6 State (Profile) ---
  final _ageController = TextEditingController();
  final _majorController = TextEditingController();
  final _expController = TextEditingController();
  final _bioController = TextEditingController();
  String? _gender;
  String? _genderPreference;

  final List<String> pageTitles = [
    "What days do you usually work out?",
    "What is your workout split?",
    "What time of day do you usually work out?",
    "Tell us about yourself",
    "What are your preferences?",
    "Write a short bio",
  ];

  @override
  void dispose() {
    _ageController.dispose();
    _majorController.dispose();
    _expController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- Helper: Robust Image Decoder (Fixes "Invalid Image Data") ---
  ImageProvider? _safeImageProvider(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }

    try {
      // 1. Handle HTTP links (Legacy data)
      if (base64String.startsWith('http')) return NetworkImage(base64String);

      // 2. Clean the string (Remove "data:image/png;base64," prefix)
      String cleanString = base64String;
      if (base64String.contains(',')) {
        cleanString = base64String.split(',').last;
      }

      // 3. Remove whitespace/newlines
      cleanString = cleanString.replaceAll(RegExp(r'\s+'), '');

      // 4. Decode
      final Uint8List bytes = base64Decode(cleanString);
      if (bytes.isEmpty) return null;

      return MemoryImage(bytes);
    } catch (e) {
      print("⚠️ Image Error: $e");
      return null; // Fail gracefully to the default Icon
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
                          // 1. Load asset from bundle
                          final String assetPath = _avatarAssets[index];
                          final ByteData bytes = await rootBundle.load(
                            assetPath,
                          );
                          final Uint8List list = bytes.buffer.asUint8List();

                          // 2. Convert to Base64 String
                          final String base64Image =
                              "data:image/png;base64,${base64Encode(list)}";

                          // 3. Update State
                          setState(() {
                            _selectedAvatarBase64 = base64Image;
                          });

                          if (mounted) Navigator.pop(ctx);
                        } catch (e) {
                          print("Error loading asset: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Could not load image. Check assets folder.",
                              ),
                            ),
                          );
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

  void toggleSelectAll(List<bool> options) {
    bool allSelected = options.every((o) => o);
    if (currentPage == 1) {
      allSelected = options.take(3).every((o) => o);
    }
    setState(() {
      for (int i = 0; i < options.length; i++) {
        if (currentPage == 1 && i == 3) {
          options[i] = false;
        } else {
          options[i] = !allSelected;
        }
      }
    });
  }

  // --- API Save Function ---
  Future<void> _saveQuizData() async {
    setState(() => _isLoading = true);

    // 1. Prepare Data
    final List<String> backendDays = [];
    final daysMap = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    for (int i = 0; i < 7; i++) {
      if (workoutDays[i]) backendDays.add(daysMap[i]);
    }

    final List<String> backendSplits = [];
    if (splitOptions[0]) backendSplits.add('ppl');
    if (splitOptions[1]) backendSplits.add('arnold');
    if (splitOptions[2]) backendSplits.add('brosplit');
    // Index 3 (Other) is skipped

    final List<String> backendTimes = [];
    if (timeOptions[0]) backendTimes.add('morning');
    if (timeOptions[1]) backendTimes.add('afternoon');
    if (timeOptions[2]) backendTimes.add('evening');

    // 2. Safe ID Check
    final String userId = widget.userData['_id'] ?? widget.userData['id'] ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error: Missing User ID')));
      setState(() => _isLoading = false);
      return;
    }

    // Use the /quiz route
    final String apiUrl = '${ApiConfig.baseUrl}/api/users/$userId/quiz';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.userData['token']}',
        },
        body: jsonEncode({
          'days': backendDays,
          'times': backendTimes,
          'splits': backendSplits,
          'profile': {
            'age': int.tryParse(_ageController.text.trim()),
            'gender': _gender,
            'major': _majorController.text.trim(),
            'bio': _bioController.text.trim(),
            'yearsOfExperience': int.tryParse(_expController.text.trim()),
            'genderPreferences': _genderPreference,
            'phone': _phoneController.text.trim(),
            // Send the Base64 string directly
            if (_selectedAvatarBase64 != null) 'photo': _selectedAvatarBase64,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // --- CRITICAL CRASH FIX ---
        // Sanitize the user map to prevent "Back to Homepage" crash
        final Map<String, dynamic> cleanUser = Map<String, dynamic>.from(
          data['user'],
        );

        if (cleanUser['profile'] != null) {
          cleanUser['profile'] = Map<String, dynamic>.from(
            cleanUser['profile'],
          );
        } else {
          cleanUser['profile'] = <String, dynamic>{};
        }

        // Re-inject token
        cleanUser['token'] = widget.userData['token'];

        if (!mounted) return;

        // Navigate safely
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MainDashboardPage(userData: cleanUser),
          ),
          (Route<dynamic> route) => false,
        );
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
      print("Quiz Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection Error. Check console.')),
      );
    }

    setState(() => _isLoading = false);
  }

  void nextPage() {
    if (currentPage < 5) {
      setState(() {
        currentPage++;
      });
    } else {
      _saveQuizData();
    }
  }

  void prevPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  // --- STYLING ---
  final kOptionStyle = const TextStyle(color: Colors.black, fontSize: 16);
  final kLabelStyle = const TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // --- Widget Builders ---

  Widget buildCheckboxList(
    List<String> labels,
    List<bool> options, {
    bool showSelectAll = false,
  }) {
    return Column(
      children: [
        ...List.generate(labels.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: CheckboxListTile(
              title: Text(labels[index], style: kOptionStyle),
              value: options[index],
              onChanged: (val) {
                setState(() {
                  options[index] = val ?? false;
                });
              },
              activeColor: Colors.yellow[700],
              checkColor: Colors.white,
              tileColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }),
        if (showSelectAll)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ElevatedButton(
              onPressed: () => toggleSelectAll(options),
              child: const Text("Select All"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget buildRadioList(
    List<String> labels,
    String? groupValue,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      children: labels.map((label) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: RadioListTile<String>(
            title: Text(label, style: kOptionStyle),
            value: label,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: Colors.yellow[700],
            tileColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: kOptionStyle,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildBioField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: kOptionStyle,
        maxLines: 5,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget pageContent;

    if (currentPage == 0) {
      pageContent = buildCheckboxList(
        [
          "Monday",
          "Tuesday",
          "Wednesday",
          "Thursday",
          "Friday",
          "Saturday",
          "Sunday",
        ],
        workoutDays,
        showSelectAll: true,
      );
    } else if (currentPage == 1) {
      pageContent = buildCheckboxList(
        ["Push/Pull/Leg", "Arnold Split", "Bro Split", "Other"],
        splitOptions,
        showSelectAll: true,
      );
    } else if (currentPage == 2) {
      pageContent = buildCheckboxList([
        "Morning",
        "Afternoon",
        "Evening",
      ], timeOptions);
    } else if (currentPage == 3) {
      // --- Page 3: Profile Info (Asset Selector) ---
      pageContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PHOTO SELECTION
          Center(
            child: GestureDetector(
              onTap: _selectAvatar,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                // Use Safe Decoder
                backgroundImage: _safeImageProvider(_selectedAvatarBase64),
                child: _selectedAvatarBase64 == null
                    ? Icon(
                        Icons.account_circle,
                        size: 50,
                        color: Colors.grey.shade400,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Tap to choose avatar",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),

          Text("Your Gender", style: kLabelStyle),
          buildRadioList(
            ["male", "female", "nonbinary", "other", "prefer not to say"],
            _gender,
            (value) => setState(() => _gender = value),
          ),
          const SizedBox(height: 20),

          buildTextField(
            _ageController,
            "Age",
            keyboardType: TextInputType.number,
          ),
          buildTextField(
            _phoneController,
            "Phone Number (Optional)",
            keyboardType: TextInputType.phone,
          ),
          buildTextField(_majorController, "Major"),
          buildTextField(
            _expController,
            "Years of Experience",
            keyboardType: TextInputType.number,
          ),
        ],
      );
    } else if (currentPage == 4) {
      pageContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Workout Partner Gender Preference", style: kLabelStyle),
          buildRadioList(
            ["coed", "single_gender", "no_preference"],
            _genderPreference,
            (value) => setState(() => _genderPreference = value),
          ),
        ],
      );
    } else {
      pageContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Bio", style: kLabelStyle),
          const SizedBox(height: 10),
          buildBioField(_bioController, "Tell your future gym buddies..."),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[currentPage]),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: SingleChildScrollView(child: pageContent)),
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.yellow)
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentPage > 0)
                      ElevatedButton(
                        onPressed: prevPage,
                        child: const Text("Back"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    if (currentPage == 0) Container(),
                    ElevatedButton(
                      onPressed: nextPage,
                      child: Text(currentPage == 5 ? "Save & Finish" : "Next"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

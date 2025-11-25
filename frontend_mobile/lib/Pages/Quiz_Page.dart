// lib/Pages/quiz_page.dart

import 'package:flutter/material.dart';
import 'main_dashboard_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const QuizPage({super.key, required this.userData});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentPage = 0;
  bool _isLoading = false;

  // --- Page 1-3 State (Checkboxes) ---
  List<bool> workoutDays = List.generate(7, (_) => false); // Mon–Sun
  // "Other" is added, so this is now 4 items
  List<bool> splitOptions = [
    false,
    false,
    false,
    false,
  ]; // Push/Pull/Leg, Arnold, Bro, Other
  List<bool> timeOptions = [false, false, false]; // Morning, Afternoon, Evening

  // --- Page 4-6 State (Profile) ---
  final _ageController = TextEditingController();
  final _majorController = TextEditingController();
  final _expController = TextEditingController();
  final _bioController = TextEditingController();
  String? _gender;
  String? _genderPreference;

  // Titles for each page
  final List<String> pageTitles = [
    "What days do you usually work out?", // Page 0
    "What is your workout split?", // Page 1
    "What time of day do you usually work out?", // Page 2
    "Tell us about yourself", // Page 3
    "What are your preferences?", // Page 4
    "Write a short bio", // Page 5
  ];

  @override
  void dispose() {
    _ageController.dispose();
    _majorController.dispose();
    _expController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // --- Select All Function ---
  void toggleSelectAll(List<bool> options) {
    // Check if all are selected, except for "Other" if it's the splits page
    bool allSelected = options.every((o) => o);
    if (currentPage == 1) {
      // Special case for splits
      allSelected = options.take(3).every((o) => o);
    }

    setState(() {
      for (int i = 0; i < options.length; i++) {
        // Don't toggle "Other"
        if (currentPage == 1 && i == 3) {
          options[i] = false;
        } else {
          options[i] = !allSelected;
        }
      }
    });
  }

  // --- API Save Function (Updated) ---
  Future<void> _saveQuizData() async {
    setState(() => _isLoading = true);

    // 1. Simulate a 1-second network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // 2. Get the selected quiz answers
      final List<String> dayLabels = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
      ];
      final List<String> splitLabels = [
        "Push/Pull/Leg",
        "Arnold Split",
        "Bro Split",
        "Other",
      ];
      final List<String> timeLabels = ["Morning", "Afternoon", "Evening"];

      final selectedDays = dayLabels
          .where((day) => workoutDays[dayLabels.indexOf(day)])
          .toList();
      final selectedSplits = splitLabels
          .where((split) => splitOptions[splitLabels.indexOf(split)])
          .toList();
      final selectedTimes = timeLabels
          .where((time) => timeOptions[timeLabels.indexOf(time)])
          .toList();

      // 3. Update the local userData object with the new data
      // (This will make your ProfilePage work!)
      widget.userData['workoutDays'] = selectedDays;
      widget.userData['workoutSplits'] = selectedSplits;
      widget.userData['workoutTimes'] = selectedTimes;
      widget.userData['hasCompletedQuiz'] = true; // Mark as "completed"

      // Also save the profile data
      widget.userData['profile'] = {
        'age': int.tryParse(_ageController.text),
        'gender': _gender,
        'major': _majorController.text.trim(),
        'bio': _bioController.text.trim(),
        'yearsOfExperience': int.tryParse(_expController.text),
        'genderPreferences': _genderPreference,
      };

      // 4. Navigate to the dashboard (no API call needed)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainDashboardPage(userData: widget.userData),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }

    setState(() => _isLoading = false);
  }

  // --- Navigation Functions ---
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

  // --- STYLING (Removed white text) ---
  final kOptionStyle = const TextStyle(color: Colors.black, fontSize: 16);
  final kLabelStyle = const TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // --- Widget Builders for Each Page ---

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
              activeColor: Colors.red[700],
              checkColor: Colors.white,
              tileColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }),
        if (showSelectAll) // <-- Show "Select All" button
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ElevatedButton(
              onPressed: () => toggleSelectAll(options),
              child: Text("Select All"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
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
            activeColor: Colors.red[700],
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
        style: kOptionStyle, // <-- Use kOptionStyle
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

    // --- Page 0: Days ---
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
        showSelectAll: true, // <-- ADDED
      );
      // --- Page 1: Splits ---
    } else if (currentPage == 1) {
      pageContent = buildCheckboxList(
        [
          "Push/Pull/Leg",
          "Arnold Split",
          "Bro Split",
          "Other",
        ], // <-- ADDED "Other"
        splitOptions,
        showSelectAll: true, // <-- ADDED
      );
      // --- Page 2: Times ---
    } else if (currentPage == 2) {
      pageContent = buildCheckboxList([
        "Morning",
        "Afternoon",
        "Evening",
      ], timeOptions);
      // --- Page 3: Profile Info ---
    } else if (currentPage == 3) {
      pageContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          buildTextField(_majorController, "Major"),
          // --- UPDATED LABEL ---
          buildTextField(
            _expController,
            "How long have you been working out? (in years)",
            keyboardType: TextInputType.number,
          ),
        ],
      );
      // --- Page 4: Gender Preferences ---
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
      // --- Page 5: Bio ---
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

    // --- BUILD SCAFFOLD (Gradient Removed) ---
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitles[currentPage],
        ), // <-- Removed white text, will use default theme
        centerTitle: true,
        backgroundColor: Colors.white, // <-- Set to solid color
        elevation: 1, // <-- Add a slight shadow
        iconTheme: IconThemeData(
          color: Colors.black,
        ), // <-- Make back button black
      ),
      backgroundColor: Colors.white, // <-- Set background to solid white
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(child: SingleChildScrollView(child: pageContent)),
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.red)
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
                    if (currentPage == 0) // Placeholder
                      Container(),
                    ElevatedButton(
                      onPressed: nextPage,
                      child: Text(currentPage == 5 ? "Save & Finish" : "Next"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
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

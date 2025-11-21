import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Styled accessories/styled_body_text.dart';
import '../Styled accessories/styled_header_text.dart';
import 'Main_Dashboard_Page.dart';

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const QuizPage({super.key, required this.userData});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  // --- Form Controllers & State ---
  final _bioController = TextEditingController();
  String? _selectedGender;
  int _age = 18;

  // --- Bitmask & Checkbox State ---
  int _questionnaireBitmask = 0;
  final Map<int, bool> _workoutTypes = {
    1: false, // Cardio
    2: false, // Strength
    4: false, // Flexibility
    8: false, // HIIT
    16: false, // Sports
  };

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  // Update bitmask when a checkbox is toggled
  void _updateBitmask(int value, bool isChecked) {
    setState(() {
      _workoutTypes[value] = isChecked;
      if (isChecked) {
        _questionnaireBitmask |= value; // Set bit
      } else {
        _questionnaireBitmask &= ~value; // Clear bit
      }
    });
  }

  // --- API Call: Submit Quiz ---
  Future<void> _submitQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation for gender and workout types
    if (_selectedGender == null) {
      setState(() => _errorMessage = "Please select your gender.");
      return;
    }
    if (_questionnaireBitmask == 0) {
      setState(
        () => _errorMessage = "Please select at least one workout type.",
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final String apiUrl = '${dotenv.env['API_BASE_URL']}/api/users/profile';
    // We need the token to make this request. For now, we'll assume it's saved
    // in a secure storage. In a real app, you'd retrieve it here.
    // final token = await SecureStorage.getToken();
    // For this example, we will skip the token header, but your backend will need it.

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // 'Authorization': 'Bearer $token', // Add your token here
        },
        body: jsonEncode({
          'userId': widget.userData['_id'], // Pass user ID
          'bio': _bioController.text.trim(),
          'age': _age,
          'gender': _selectedGender,
          'questionnaireBitmask': _questionnaireBitmask,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedUser = data['user'];

        // Navigate to Dashboard with updated user data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainDashboardPage(userData: updatedUser),
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Failed to submit quiz.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not connect to the server.';
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup Your Profile"),
        backgroundColor: Colors.red[800],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const StyledHeaderText("Tell Us About Yourself", fontSize: 24),
              const SizedBox(height: 20),

              // --- Bio ---
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Short Bio',
                  border: OutlineInputBorder(),
                  hintText: 'I love lifting and running...',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a short bio.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Age & Gender ---
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _age,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(83, (index) => index + 18)
                          .map(
                            (age) => DropdownMenuItem(
                              value: age,
                              child: Text(age.toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _age = value!),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Male', 'Female', 'Other']
                          .map(
                            (gender) => DropdownMenuItem(
                              value: gender.toLowerCase(),
                              child: Text(gender),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedGender = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- Workout Types (Bitmask) ---
              const StyledHeaderText(
                "What are your workout interests?",
                fontSize: 18,
              ),
              const SizedBox(height: 10),
              ..._workoutTypes.entries.map((entry) {
                final name = {
                  1: 'Cardio (Running, Cycling)',
                  2: 'Strength Training (Lifting)',
                  4: 'Flexibility (Yoga, Pilates)',
                  8: 'HIIT / Crossfit',
                  16: 'Sports (Basketball, Soccer, etc.)',
                }[entry.key]!;

                return CheckboxListTile(
                  title: Text(name),
                  value: entry.value,
                  activeColor: Colors.red[800],
                  onChanged: (bool? value) {
                    _updateBitmask(entry.key, value!);
                  },
                );
              }).toList(),

              const SizedBox(height: 30),

              // --- Error Message ---
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitQuiz,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Complete Profile',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

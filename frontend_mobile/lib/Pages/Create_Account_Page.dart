import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv directly
import '../Styled accessories/styled_body_text.dart';
import '../Styled accessories/styled_header_text.dart';
import 'Email_Verification_Pending_Page.dart';
import '../services/api_config.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  // Text editing controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phonenumberController = TextEditingController();

  // State variables
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  // API URL initialized directly from dotenv
  final String _apiUrl = '${ApiConfig.baseUrl}/api/auth/signup';

  @override
  void dispose() {
    // Clean up controllers
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phonenumberController.dispose();
    super.dispose();
  }

  Future<void> _signupUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = "Passwords do not match.";
        _isLoading = false;
      });
      return;
    }
    final String emailInput = emailController.text.trim().toLowerCase();
    if (!emailInput.endsWith('@ucf.edu') &&
        !emailInput.endsWith('@mail.valenciacollege.edu')) {
      setState(() {
        _errorMessage =
            "Please use a valid @ucf.edu or @mail.valenciacollege.edu email.";
        _isLoading = false;
      });
      return;
    }
    if (phonenumberController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please enter your phone number.";
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": usernameController.text.trim(),
          "email": emailController.text.trim(),
          "phone": phonenumberController.text.trim(),
          "password": passwordController.text.trim(),
          "confirmpassword": confirmPasswordController.text.trim(),
        }),
      );

      // --- 1. CHECK IF RESPONSE IS JSON ---
      final String responseBody = response.body;
      if (responseBody.isEmpty || responseBody[0] != '{') {
        // This is not JSON, it's an error page (e.g., HTML)
        throw FormatException(
          "Server returned an invalid response (not JSON).",
        );
      }

      final data = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        // --- 2. SIGNUP SUCCESSFUL ---
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationPendingPage(
              email: emailController.text.trim(),
            ),
          ),
        );
      } else {
        // --- 3. REAL BACKEND ERROR ---
        setState(() {
          _errorMessage = data['message'] ?? 'Signup failed. Try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      // --- 4. IMPROVED CATCH BLOCK ---
      // This will now show you the FormatException or the connection error
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
      print("Signup Error: $e"); // Print the full error for debugging
    }

    if (_errorMessage.isNotEmpty) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      // --- Background Gradient ---
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              Colors.yellow[800]!,
              Colors.yellow[600]!,
              Colors.yellow[400]!,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 80),
            // --- Header Text ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  StyledHeaderText(
                    'Create Account',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  StyledBodyText(
                    "Join us and find your gym buddy!",
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // --- White Container Block ---
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 30),
                        // --- Input Fields Container ---
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 226, 226, 226),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              // --- Username Input ---
                              _buildInputField(
                                controller: usernameController,
                                hintText: 'Username',
                                icon: Icons.person_outline,
                              ),
                              // --- Email Input ---
                              _buildInputField(
                                controller: emailController,
                                hintText: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              // --- Phone Input ---
                              _buildInputField(
                                controller: phonenumberController,
                                hintText: 'Phone Number',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                              ),
                              // --- Password Input ---
                              _buildInputField(
                                controller: passwordController,
                                hintText: 'Password',
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                              // --- Confirm Password Input ---
                              _buildInputField(
                                controller: confirmPasswordController,
                                hintText: 'Confirm Password',
                                icon: Icons.lock_outline,
                                obscureText: true,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // --- Error Message Display ---
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // --- Signup Button ---
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.yellow[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            // Disable button while loading
                            onPressed: _isLoading ? null : _signupUser,
                            child: _isLoading
                                // Show loading spinner if loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                // Show text otherwise
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // --- Back to Login Link ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.yellow[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build consistent input fields
  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.yellow[300]),
        ),
      ),
    );
  }
}

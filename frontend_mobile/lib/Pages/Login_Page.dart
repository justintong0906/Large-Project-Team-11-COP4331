import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv directly
import '../Styled accessories/styled_body_text.dart';
import '../Styled accessories/styled_header_text.dart';
import 'Email_Verification_Pending_Page.dart';
import 'Quiz_Page.dart';
import 'Main_Dashboard_Page.dart';
import 'Forgot_Password_Page.dart';
import '../config.dart';
import 'Create_Account_Page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  // State variables
  bool _isLoading = false;
  String _errorMessage = '';

  // API URL initialized directly from dotenv
  final String _apiUrl = '${dotenv.env['API_BASE_URL']}/api/auth/login';

  @override
  void dispose() {
    // Clean up controllers when the widget is removed from the widget tree
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    // 1. Reset state and show loading spinner
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 2. Make API Request
      final response = await http.post(
        Uri.parse(_apiUrl), // Use the directly initialized URL
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'identifier': emailTextController.text.trim(),
          'password': passwordTextController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      // 3. Handle Response
      if (response.statusCode == 200) {
        // --- SUCCESSFUL LOGIN ---
        print('Login successful: $data');

        final Map<String, dynamic> userData = data['user'];
        // TODO: Save token securely

        // Check bitmask to see if quiz is done
        final bool userHasCompletedQuiz =
            (userData['questionnaireBitmask'] ?? 0) > 0;

        if (!mounted) return; // Check if user is still on the page

        // Navigate to the appropriate page
        if (!userHasCompletedQuiz) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPage(userData: userData),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainDashboardPage(userData: userData),
            ),
          );
        }
      } else if (response.statusCode == 403) {
        // --- NOT VERIFIED ERROR ---
        // The backend says the email isn't verified yet.
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationPendingPage(
              // Pass the email they just typed so they can resend
              email: emailTextController.text.trim(),
            ),
          ),
        );
      } else {
        // --- OTHER ERRORS (e.g., Wrong password, 401, 404) ---
        setState(() {
          _errorMessage = data['message'] ?? 'Login failed';
        });
      }
    } catch (e) {
      print("Login Error: $e");
      // --- CONNECTION ERRORS ---
      setState(() {
        _errorMessage =
            'Could not connect to the server. Please check your internet and .env configuration.';
      });
    }

    // 4. Stop loading spinner (if we are still on this screen)
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      // --- Background Gradient ---
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [Colors.red[800]!, Colors.red[600]!, Colors.red[300]!],
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
                    'Login',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  StyledBodyText(
                    "Welcome Back",
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
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
                        const SizedBox(height: 40),
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
                              // --- Email Input ---
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  controller: emailTextController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'Email or Username',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: Colors.red[300],
                                    ),
                                  ),
                                ),
                              ),
                              // --- Password Input ---
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  controller: passwordTextController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Colors.red[300],
                                    ),
                                  ),
                                ),
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
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // --- Forgot Password Link ---
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // --- Login Button ---
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            // Disable button while loading
                            onPressed: _isLoading ? null : _loginUser,
                            child: _isLoading
                                // Show loading spinner if loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                // Show text otherwise
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
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
}

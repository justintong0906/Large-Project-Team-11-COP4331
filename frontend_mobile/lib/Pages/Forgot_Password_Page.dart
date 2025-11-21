import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Styled accessories/styled_body_text.dart';
import '../Styled accessories/styled_header_text.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  bool _isError = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- API Call: Request Password Reset ---
  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _message = 'Please enter your email address.';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
      _isError = false;
    });

    // This endpoint doesn't exist in your backend yet, but this is
    // where you would point it once you build it.
    final String apiUrl =
        '${dotenv.env['API_BASE_URL']}/api/auth/forgot-password';

    try {
      // --- MOCK API CALL (Replace with real call later) ---
      // Since your backend doesn't have this route, we'll simulate a successful call.
      //
      // final response = await http.post(
      //   Uri.parse(apiUrl),
      //   headers: {'Content-Type': 'application/json; charset=UTF-8'},
      //   body: jsonEncode({'email': email}),
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   setState(() {
      //     _message = data['message'] ?? 'Reset link sent to your email.';
      //     _isError = false;
      //   });
      //   _emailController.clear(); // Clear the field on success
      // } else { ...handle error... }

      // --- SIMULATED SUCCESS ---
      await Future.delayed(const Duration(seconds: 2)); // Fake network delay
      setState(() {
        _message =
            'If an account exists for $email, a reset link has been sent.';
        _isError = false;
      });
      _emailController.clear();
    } catch (e) {
      setState(() {
        _message = 'Could not connect to the server.';
        _isError = true;
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Use a red gradient background consistent with other pages ---
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Back Button ---
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              // --- Header ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    StyledHeaderText('Forgot Password', color: Colors.white),
                    SizedBox(height: 10),
                    StyledBodyText(
                      "Enter your email to receive a reset link.",
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // --- White Container for Content ---
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        // --- Email Input Field ---
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.grey.shade600),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.red[300],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // --- Error/Success Message ---
                        if (_message.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              _message,
                              style: TextStyle(
                                color: _isError ? Colors.red : Colors.green,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        // --- Send Button ---
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: _isLoading ? null : _sendResetLink,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Send Reset Link',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
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

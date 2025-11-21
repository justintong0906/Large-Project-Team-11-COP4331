import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // For the resend timer

import '../Styled accessories/styled_body_text.dart';
import '../Styled accessories/styled_header_text.dart';
import 'Login_Page.dart';

class EmailVerificationPendingPage extends StatefulWidget {
  // We must pass the user's email to this page
  final String email;

  const EmailVerificationPendingPage({super.key, required this.email});

  @override
  State<EmailVerificationPendingPage> createState() =>
      _EmailVerificationPendingPageState();
}

class _EmailVerificationPendingPageState
    extends State<EmailVerificationPendingPage> {
  String _message = '';
  bool _isError = false;

  // --- Resend Button Logic ---
  bool _canResend = false;
  int _timerCountdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the page is closed
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _canResend = false);
    _timerCountdown = 30; // Reset timer

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerCountdown > 0) {
        if (mounted) setState(() => _timerCountdown--);
      } else {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      }
    });
  }

  // --- API Call: Resend Code ---
  Future<void> _resendCode() async {
    _startResendTimer();
    setState(() {
      _message = '';
      _isError = false;
    });

    // This matches your backend's auth.controller.js
    final String apiUrl =
        '${dotenv.env['API_BASE_URL']}/api/auth/resend-verification';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': widget.email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _message =
              data['message'] ?? 'A new verification email has been sent.';
          _isError = false;
        });
      } else {
        setState(() {
          _message = data['message'] ?? 'Error resending email.';
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Could not connect to the server.';
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
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
            const Padding(
              padding: EdgeInsets.all(20),
              child: StyledHeaderText(
                'Check Your Email',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.email_outlined,
                          color: Colors.red[700],
                          size: 80,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "We've sent a verification link to:\n${widget.email}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Please check your inbox (and spam folder) to continue.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 40),
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
                        // --- "Back to Login" Button ---
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
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: const Text(
                              'Back to Login',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // --- "Resend" Button ---
                        TextButton(
                          onPressed: _canResend ? _resendCode : null,
                          child: Text(
                            _canResend
                                ? 'Resend Email'
                                : 'Resend email in $_timerCountdown s',
                            style: TextStyle(
                              color: _canResend ? Colors.red[700] : Colors.grey,
                            ),
                          ),
                        ),
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

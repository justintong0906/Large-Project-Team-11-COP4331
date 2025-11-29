import 'package:flutter/material.dart';
import 'Login_Page.dart';
import 'Create_Account_Page.dart';
import 'Forgot_Password_Page.dart';
import '../Styled accessories/styled_body_text.dart';
import '../Styled accessories/styled_header_text.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the total screen height
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
              Colors.yellow[300]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight - 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // --- TOP SECTION: LOGO & TEXT ---
                  Column(
                    children: <Widget>[
                      const SizedBox(height: 60), // Added top spacing
                      const StyledHeaderText(
                        'Welcome to',
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                      const SizedBox(height: 10),
                      const StyledHeaderText(
                        'Gym Buddy',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: StyledBodyText(
                          "Find your perfect workout partner and achieve your goals together.",
                          color: Colors.white.withOpacity(0.9),
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 50),
                      // --- LOGO PLACEHOLDER ---
                      Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.fitness_center_rounded,
                          size: 80,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),

                  // --- BOTTOM SECTION: BUTTONS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ), // Side padding for buttons
                    child: Column(
                      children: <Widget>[
                        // --- LOGIN BUTTON ---
                        SizedBox(
                          width: double.infinity,
                          height: 65, // Made slightly taller
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.yellow[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, // Bold
                                fontSize: 20, // Bigger font
                                color: Colors.yellow[800],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- CREATE ACCOUNT BUTTON (Now same style as Login) ---
                        SizedBox(
                          width: double.infinity,
                          height: 65, // Made slightly taller
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.yellow[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              elevation: 5,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateAccountPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, // Bold
                                fontSize: 20, // Bigger font
                                color: Colors.yellow[800],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // --- FORGOT PASSWORD BUTTON ---
                        TextButton(
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
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration:
                                  TextDecoration.underline, // Underlined
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

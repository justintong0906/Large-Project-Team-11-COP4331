import 'package:flutter/material.dart';
import 'Login_Page.dart';
import 'Create_Account_Page.dart';
import '../Styled accessories/styled_body_text.dart';
import '../Styled accessories/styled_header_text.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- BACKGROUND GRADIENT ---
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // --- TOP SECTION: TITLE & LOGO ---
                Column(
                  children: <Widget>[
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
                      ),
                    ),
                    const SizedBox(height: 50),
                    // --- LOGO PLACEHOLDER ---
                    // Replace this Icon with your app's logo image
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
                Column(
                  children: <Widget>[
                    // --- LOGIN BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.red[800],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // --- CREATE ACCOUNT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CreateAccountPage()),
                          );
                        },
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
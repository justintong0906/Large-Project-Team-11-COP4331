import 'dart:io'; // Required for Platform detection
import 'package:flutter/foundation.dart'; // Required for kDebugMode

class Config {
  // This getter automatically chooses the right URL for the emulator being used.
  static String get baseUrl {
    // 1. Android Emulator
    if (Platform.isAndroid) {
      // This is the special IP that points back to your computer's localhost.
      // It works on every Android emulator, on every team member's computer.
      print("🤖 Config: Android Emulator detected. Using 10.0.2.2");
      return 'http://10.0.2.2:5001';
    }

    // 2. iOS Simulator (Mac only)
    if (Platform.isIOS) {
      // iOS simulators can just use localhost.
      print("🍎 Config: iOS Simulator detected. Using localhost.");
      return 'http://localhost:5001';
    }

    // 3. Fallback/Error case
    // This should never be reached if everyone is using an emulator.
    return 'http://localhost:5001';
  }

  // Helper getters for your pages to use
  static String get loginUrl => '$baseUrl/api/auth/login';
  static String get signupUrl => '$baseUrl/api/auth/signup';
}

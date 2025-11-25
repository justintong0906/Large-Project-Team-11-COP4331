// lib/services/api_config.dart
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl {
    // 1. Get the URL from .env (defaults to localhost)
    String url = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5001';

    // 2. If we are on the Android Emulator, swap 'localhost' for '10.0.2.2'
    if (Platform.isAndroid && url.contains('localhost')) {
      url = url.replaceFirst('localhost', '10.0.2.2');
    }

    return url;
  }
}

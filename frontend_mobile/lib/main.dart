import 'package:flutter/material.dart';
import 'Pages/Home_Page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Pages/Login_Page.dart'; // Adjust path if needed

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()),
  );
}

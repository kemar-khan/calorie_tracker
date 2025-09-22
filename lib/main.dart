import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:calorie_tracker/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // required
  await Firebase.initializeApp(); // must wait before runApp
  runApp(const CalorieApp());
}

class CalorieApp extends StatelessWidget {
  const CalorieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoginScreen(),
    );
  }
}

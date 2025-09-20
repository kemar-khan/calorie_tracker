import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(CalorieApp());

class CalorieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Tracker',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomeScreen(),
    );
  }
}

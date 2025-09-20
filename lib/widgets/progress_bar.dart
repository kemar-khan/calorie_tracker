import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int totalCalories;
  final int goal;

  const ProgressBar({
    super.key,
    required this.totalCalories,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Daily Goal: $goal kcal"),
        SizedBox(height: 10),
        LinearProgressIndicator(
          value: totalCalories / goal,
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          color: Colors.green,
        ),
        SizedBox(height: 10),
        Text("Total: $totalCalories kcal"),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../models/food.dart';
import '../widgets/food_list.dart';
import '../widgets/progress_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Food> foods = [];
  final foodController = TextEditingController();
  final calorieController = TextEditingController();
  final int dailyGoal = 2000;

  void addFood() {
    if (foodController.text.isEmpty || calorieController.text.isEmpty) return;

    setState(() {
      foods.add(
        Food(
          name: foodController.text,
          calories: int.parse(calorieController.text),
        ),
      );
    });

    foodController.clear();
    calorieController.clear();
    Navigator.pop(context);
  }

  int get totalCalories {
    return foods.fold(0, (sum, item) => sum + item.calories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calorie Tracker")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ProgressBar(totalCalories: totalCalories, goal: dailyGoal),
          ),
          Divider(),
          Expanded(child: FoodList(foods: foods)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Add Food"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: foodController,
                    decoration: InputDecoration(labelText: "Food name"),
                  ),
                  TextField(
                    controller: calorieController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Calories"),
                  ),
                ],
              ),
              actions: [ElevatedButton(onPressed: addFood, child: Text("Add"))],
            ),
          );
        },
      ),
    );
  }
}

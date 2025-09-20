import 'package:flutter/material.dart';
import '../models/food.dart';

class FoodList extends StatelessWidget {
  final List<Food> foods;

  const FoodList({super.key, required this.foods});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final item = foods[index];
        return Card(
          child: ListTile(
            title: Text(item.name),
            subtitle: Text("${item.calories} kcal"),
          ),
        );
      },
    );
  }
}

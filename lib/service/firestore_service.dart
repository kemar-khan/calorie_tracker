import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../models/food.dart';
import '../models/daily_calories.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // --------------------------
  // USER METHODS
  // --------------------------

  Future<void> createUser(AppUser user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      try {
        return AppUser.fromMap(doc.data()!);
      } catch (e) {
        log("Error parsing user: $e");
      }
    }
    return null;
  }

  // --------------------------
  // FOOD METHODS
  // --------------------------

  Future<void> addFood(Food food) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("No authenticated user");

    try {
      final docRef = await _db.collection('foods').add({
        'name': food.name,
        'calories': food.calories,
        'uid': user.uid,
        'date': food.date,
        'servingSize': food.servingSize,
        'mealTime': food.mealTime,
      });

      // update the id field inside the food doc (so you can delete/edit later)
      await _db.collection('foods').doc(docRef.id).update({'id': docRef.id});
    } catch (e) {
      log("Error adding food: $e");
    }
  }

  Future<List<Food>> getFoodsByUser(String uid) async {
    try {
      final snapshot = await _db
          .collection('foods')
          .where('uid', isEqualTo: uid)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => Food.fromMap(doc.data())).toList();
    } catch (e) {
      log("Error fetching foods: $e");
      return [];
    }
  }

  Future<void> deleteFood(String foodId) async {
    try {
      await _db.collection('foods').doc(foodId).delete();
    } catch (e) {
      log("Error deleting food: $e");
    }
  }

  Future<void> updateFood(Food food) async {
    try {
      await _db.collection('foods').doc(food.id).update(food.toMap());
    } catch (e) {
      log("Error updating food: $e");
    }
  }

  // --------------------------
  // DAILY CALORIES METHODS (computed from foods)
  // --------------------------

  Future<int> getTodayConsumedCalories() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    final uid = user.uid;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final snapshot = await _db
          .collection('foods')
          .where('uid', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .get();

      int totalCalories = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalCalories += (data['calories'] ?? 0) as int;
      }

      return totalCalories;
    } catch (e) {
      log("Error fetching today's calories: $e");
      return 0;
    }
  }

  Future<int> getDailyGoal() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    final uid = user.uid;

    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return (data['dailyGoal'] is int)
          ? data['dailyGoal'] as int
          : int.tryParse(data['dailyGoal'].toString()) ?? 2000;
    }
    return 2000; // default fallback
  }

  Future<void> updateDailyGoal(int newGoal) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    final uid = user.uid;

    await _db.collection('users').doc(uid).set({
      'dailyGoal': newGoal,
    }, SetOptions(merge: true));
  }

  // --------------------------
  // STREAM HELPERS
  // --------------------------

  Stream<QuerySnapshot> getFoods() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    return _db
        .collection('foods')
        .where('uid', isEqualTo: user.uid)
        .snapshots();
  }

  Stream<QuerySnapshot> getTodayFoods() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return _db
        .collection('foods')
        .where('uid', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .snapshots();
  }
}

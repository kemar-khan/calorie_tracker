class Food {
  final String id;
  final String uid;
  final String name;
  final int calories;
  final String servingSize;
  final String mealTime; // breakfast, lunch, dinner, snack
  final DateTime? date;
  final String notes;

  Food({
    required this.id,
    required this.uid,
    required this.name,
    required this.calories,
    required this.servingSize,
    required this.mealTime,
    this.date,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'calories': calories,
      'servingSize': servingSize,
      'mealTime': mealTime,
      'date': date?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
      servingSize: map['servingSize'] ?? '',
      mealTime: map['mealTime'] ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
      notes: map['notes'] ?? '',
    );
  }
}

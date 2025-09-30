class DailyCalories {
  final String consumed;
  final String goal;
  final String remaining;

  DailyCalories({
    required this.consumed,
    required this.goal,
    required this.remaining,
  });

  factory DailyCalories.fromMap(Map<String, dynamic> data) {
    final consumed = data['consumed'] ?? 0;
    final goal = data['goal'] ?? 2000; // default fallback
    return DailyCalories(
      consumed: consumed,
      goal: goal,
      remaining: goal - consumed,
    );
  }

  Map<String, dynamic> toMap() {
    return {'consumed': consumed, 'goal': goal};
  }
}

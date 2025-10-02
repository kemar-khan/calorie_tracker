import 'package:calorie_tracker/screens/add_food_screen.dart';
import 'package:flutter/material.dart';
import '../service/firestore_service.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final FirestoreService firestoreService = FirestoreService();

  // Sample data - replace with actual data from your database
  final int dailyGoal = 2000;
  final int totalConsumed = 1750;
  final int breakfast = 400;
  final int lunch = 650;
  final int dinner = 500;
  final int snacks = 200;

  // Macros (in grams)
  final int carbs = 180;
  final int protein = 95;
  final int fat = 65;

  // Water intake (glasses)
  int waterGlasses = 6;
  final int waterGoal = 8;

  // Recent foods
  final List<Map<String, dynamic>> recentFoods = [
    {'name': 'Grilled Chicken', 'calories': 250},
    {'name': 'Brown Rice', 'calories': 200},
    {'name': 'Greek Yogurt', 'calories': 150},
    {'name': 'Apple', 'calories': 95},
    {'name': 'Almonds', 'calories': 160},
  ];

  // Weekly progress
  final List<Map<String, dynamic>> weeklyData = [
    {'day': 'Mon', 'calories': 1850},
    {'day': 'Tue', 'calories': 1950},
    {'day': 'Wed', 'calories': 1700},
    {'day': 'Thu', 'calories': 2100},
    {'day': 'Fri', 'calories': 1800},
    {'day': 'Sat', 'calories': 1900},
    {'day': 'Sun', 'calories': 1750},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int get remainingCalories => dailyGoal - totalConsumed;
  double get progressPercentage => totalConsumed / dailyGoal;

  Color get progressColor {
    if (progressPercentage <= 0.5) return Colors.green;
    if (progressPercentage <= 0.8) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Modern App Bar
            SliverAppBar(
              expandedHeight: 90,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
                child: const FlexibleSpaceBar(
                  title: Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Motivation Tip Card
                      _buildMotivationCard(),
                      const SizedBox(height: 20),

                      // Daily Summary Card
                      _buildDailySummaryCard(),
                      const SizedBox(height: 20),

                      // Meal Breakdown Section
                      StreamBuilder<Map<String, List<Map<String, dynamic>>>>(
                        stream: firestoreService.getFoodsByMeal(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final meals = snapshot.data!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Meal Breakdown',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                              const SizedBox(height: 16),

                              ...meals.entries.map((entry) {
                                final mealName = entry.key;
                                final foods = entry.value;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildMealCard(
                                    mealName,
                                    _getMealIcon(mealName),
                                    foods.fold<int>(
                                      0,
                                      (sum, food) =>
                                          sum + (food['calories'] as int),
                                    ),
                                    _getMealEmoji(mealName),
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Macronutrient Breakdown
                      _buildMacronutrientCard(),
                      const SizedBox(height: 20),

                      // Water Intake
                      _buildWaterIntakeCard(),
                      const SizedBox(height: 20),

                      // Recent Foods
                      _buildRecentFoodsCard(),
                      const SizedBox(height: 20),

                      // Weekly Progress
                      _buildWeeklyProgressCard(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMealIcon(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'breakfast':
        return Icons.egg_outlined;
      case 'lunch':
        return Icons.rice_bowl_outlined;
      case 'dinner':
        return Icons.dinner_dining_outlined;
      case 'snacks':
        return Icons.cookie_outlined;
      default:
        return Icons.fastfood; // fallback
    }
  }

  String _getMealEmoji(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'breakfast':
        return '🍳';
      case 'lunch':
        return '🍛';
      case 'dinner':
        return '🍲';
      case 'snacks':
        return '🍫';
      default:
        return '🥗';
    }
  }

  Widget _buildMotivationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Tip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Stay hydrated! Drink water throughout the day.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard() {
    final firestoreService = FirestoreService();

    return StreamBuilder<int>(
      stream: firestoreService.getTodayConsumedCalories(),
      builder: (context, consumedSnapshot) {
        if (consumedSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (consumedSnapshot.hasError) {
          return Text("Error: ${consumedSnapshot.error}");
        }

        final consumed = consumedSnapshot.data ?? 0;

        return StreamBuilder<int>(
          stream: firestoreService.getDailyGoal(),
          builder: (context, goalSnapshot) {
            if (goalSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (goalSnapshot.hasError) {
              return Text("Error: ${goalSnapshot.error}");
            }

            final goal = goalSnapshot.data ?? 2000;
            final remaining = goal - consumed;
            final progress = (goal > 0) ? (consumed / goal) : 0.0;

            Color progressColor;
            if (progress < 0.5) {
              progressColor = Colors.green;
            } else if (progress < 1.0) {
              progressColor = Colors.orange;
            } else {
              progressColor = Colors.red;
            }

            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Today\'s Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: progressColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              color: progressColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn(
                          'Consumed',
                          '$consumed',
                          Icons.restaurant,
                          Colors.blue,
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.grey.shade200,
                        ),
                        _buildStatColumn(
                          'Remaining',
                          '$remaining',
                          Icons.flag,
                          progressColor,
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.grey.shade200,
                        ),
                        _buildStatColumn(
                          'Goal',
                          '$goal',
                          Icons.track_changes,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMealCard(
    String mealName,
    IconData icon,
    int calories,
    String emoji,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$calories kcal',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$calories',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF667eea)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddFoodScreen()),
                );
              },
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrientCard() {
    final totalMacros = carbs + protein + fat;
    final carbsPercent = (carbs / totalMacros * 100).toInt();
    final proteinPercent = (protein / totalMacros * 100).toInt();
    final fatPercent = (fat / totalMacros * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Macronutrients',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 20),

          // Pie Chart
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: PieChartPainter(
                    carbsPercent: carbsPercent / 100,
                    proteinPercent: proteinPercent / 100,
                    fatPercent: fatPercent / 100,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildMacroRow('Carbs', carbs, carbsPercent, Colors.blue),
                    const SizedBox(height: 12),
                    _buildMacroRow(
                      'Protein',
                      protein,
                      proteinPercent,
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildMacroRow('Fat', fat, fatPercent, Colors.orange),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String name, int grams, int percent, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3436),
            ),
          ),
        ),
        Text(
          '${grams}g',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percent%',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildWaterIntakeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Water Intake',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              Text(
                '$waterGlasses / $waterGoal glasses',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Water glasses
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(waterGoal, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    waterGlasses = index + 1;
                  });
                },
                child: Icon(
                  index < waterGlasses
                      ? Icons.water_drop
                      : Icons.water_drop_outlined,
                  color: index < waterGlasses
                      ? Colors.blue
                      : Colors.grey.shade300,
                  size: 32,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFoodsCard() {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestoreService.getRecentFoods(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No recent foods yet.");
        }

        final recentFoods = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Foods',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🔹 Build recent food list from Firestore
              ...recentFoods.map(
                (food) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          food['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ),
                      Text(
                        '${food['calories']} kcal',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        color: const Color(0xFF667eea),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddFoodScreen(),
                            ),
                          );
                        },
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeeklyProgressCard() {
    final maxCalories = weeklyData
        .map((d) => d['calories'] as int)
        .reduce(math.max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 20),

          // Bar chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weeklyData.map((data) {
              final calories = data['calories'] as int;
              final height = (calories / maxCalories * 120).toDouble();
              final isToday = data['day'] == 'Sun'; // Assuming today is Sunday

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    calories.toString(),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isToday
                            ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
                            : [Colors.grey.shade300, Colors.grey.shade200],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['day'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday
                          ? const Color(0xFF667eea)
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Custom Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final double carbsPercent;
  final double proteinPercent;
  final double fatPercent;

  PieChartPainter({
    required this.carbsPercent,
    required this.proteinPercent,
    required this.fatPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -math.pi / 2;

    // Carbs (Blue)
    paint.color = Colors.blue;
    final carbsSweep = 2 * math.pi * carbsPercent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      carbsSweep,
      true,
      paint,
    );
    startAngle += carbsSweep;

    // Protein (Green)
    paint.color = Colors.green;
    final proteinSweep = 2 * math.pi * proteinPercent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      proteinSweep,
      true,
      paint,
    );
    startAngle += proteinSweep;

    // Fat (Orange)
    paint.color = Colors.orange;
    final fatSweep = 2 * math.pi * fatPercent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fatSweep,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

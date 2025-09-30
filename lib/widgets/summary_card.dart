import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({Key? key}) : super(key: key);

  // Helper for building each column
  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final today = DateTime.now();
    final dateKey = "${today.year}-${today.month}-${today.day}";

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('dailyCalories')
        .doc(dateKey);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<DocumentSnapshot>(
          stream: docRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text("No data for today yet.");
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final consumed = data['consumed'] ?? 0;
            final goal = data['goal'] ?? 2000;
            final remaining = goal - consumed;
            final progressPercentage = goal > 0 ? consumed / goal : 0.0;
            final progressColor = progressPercentage < 0.5
                ? Colors.green
                : Colors.red;

            return Column(
              children: [
                // Top row with percentage
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
                        '${(progressPercentage * 100).toInt()}%',
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

                // Stats row
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
            );
          },
        ),
      ),
    );
  }
}

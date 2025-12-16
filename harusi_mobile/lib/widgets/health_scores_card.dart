import 'package:flutter/material.dart';
import '../models/wedding_analytics.dart';

class HealthScoresCard extends StatelessWidget {
  final WeddingAnalytics analytics;

  const HealthScoresCard({Key? key, required this.analytics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Planning Health',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildHealthScore(
              'Overall',
              analytics.overallHealthScore,
              Colors.purple,
              isLarge: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildHealthScore(
                    'Guest',
                    analytics.guestHealthScore,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHealthScore(
                    'Budget',
                    analytics.budgetHealthScore,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildHealthScore(
                    'Tasks',
                    analytics.taskHealthScore,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHealthScore(
                    'Planning',
                    analytics.planningHealthScore,
                    Colors.pink,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScore(String label, double score, Color color,
      {bool isLarge = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 16 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: isLarge ? 100 : 70,
              height: isLarge ? 100 : 70,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: isLarge ? 10 : 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '${score.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: isLarge ? 24 : 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
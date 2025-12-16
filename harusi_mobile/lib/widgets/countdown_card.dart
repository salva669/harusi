import 'package:flutter/material.dart';
import '../models/wedding_analytics.dart';

class CountdownCard extends StatelessWidget {
  final WeddingAnalytics analytics;

  const CountdownCard({Key? key, required this.analytics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink[300]!, Colors.purple[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              '${analytics.daysUntilWedding} Days',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${analytics.weeksUntilWedding} weeks until your special day!',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

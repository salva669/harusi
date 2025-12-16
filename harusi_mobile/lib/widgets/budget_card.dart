import 'package:flutter/material.dart';
import '../models/wedding_analytics.dart';

class BudgetCard extends StatelessWidget {
  final WeddingAnalytics analytics;

  const BudgetCard({Key? key, required this.analytics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final estimated = analytics.totalEstimatedBudget;
    final actual = analytics.totalActualSpending;
    final variance = analytics.budgetVariance;
    final percentage = estimated > 0 ? (actual / estimated * 100) : 0.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBudgetItem('Estimated', estimated, Colors.blue),
                _buildBudgetItem('Spent', actual, Colors.orange),
                _buildBudgetItem(
                  'Variance',
                  variance.abs(),
                  variance >= 0 ? Colors.green : Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Budget Used', style: TextStyle(color: Colors.grey[600])),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: percentage > 100 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage > 100 ? Colors.red : Colors.green,
                  ),
                  minHeight: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          'TZS ${amount.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

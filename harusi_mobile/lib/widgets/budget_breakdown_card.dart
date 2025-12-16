import 'package:flutter/material.dart';
import '../models/wedding_analytics.dart';

class BudgetBreakdownCard extends StatelessWidget {
  final WeddingAnalytics analytics;

  const BudgetBreakdownCard({Key? key, required this.analytics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (analytics.budgetCategoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Breakdown by Category',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...analytics.budgetCategoryBreakdown.entries.map((entry) {
              final amount = double.parse(entry.value.toString());
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                          'TZS ${amount.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: analytics.totalEstimatedBudget > 0
                          ? amount / analytics.totalEstimatedBudget
                          : 0,
                      backgroundColor: Colors.grey[200],
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
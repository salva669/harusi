import 'package:flutter/material.dart';
import '../models/wedding_analytics.dart';

class TaskProgressCard extends StatelessWidget {
  final WeddingAnalytics analytics;

  const TaskProgressCard({Key? key, required this.analytics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completed = analytics.completedTasks;
    final pending = analytics.pendingTasks;
    final overdue = analytics.overdueTasks;
    final total = analytics.totalTasks;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Completed', completed.toString(), Icons.check_box, Colors.green),
                _buildStatColumn('Pending', pending.toString(), Icons.pending_actions, Colors.blue),
                _buildStatColumn('Overdue', overdue.toString(), Icons.warning, Colors.red),
                _buildStatColumn('Total', total.toString(), Icons.list_alt, Colors.purple),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Completion Rate'),
                    Text(
                      '${analytics.completionPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: analytics.completionPercentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

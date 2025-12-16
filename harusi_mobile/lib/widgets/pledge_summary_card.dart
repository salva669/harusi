import 'package:flutter/material.dart';
import '../models/pledge_summary.dart';

class PledgeSummaryCard extends StatelessWidget {
  final PledgeSummary pledgeSummary;

  const PledgeSummaryCard({Key? key, required this.pledgeSummary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final collectionRate = pledgeSummary.totalPledged > 0
        ? (pledgeSummary.totalPaid / pledgeSummary.totalPledged * 100)
        : 0.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guest Pledges',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBudgetItem('Pledged', pledgeSummary.totalPledged, Colors.blue),
                _buildBudgetItem('Collected', pledgeSummary.totalPaid, Colors.green),
                _buildBudgetItem('Balance', pledgeSummary.totalBalance, Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Collection Rate', style: TextStyle(color: Colors.grey[600])),
                    Text(
                      '${collectionRate.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: collectionRate / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 10,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPledgeStatChip('Total Pledgers', pledgeSummary.totalPledgers.toString(), Icons.people, Colors.blue),
                _buildPledgeStatChip('Fully Paid', pledgeSummary.fullyPaidCount.toString(), Icons.check_circle, Colors.green),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPledgeStatChip('Partial', pledgeSummary.partiallyPaidCount.toString(), Icons.access_time, Colors.orange),
                _buildPledgeStatChip('Unpaid', pledgeSummary.unpaidCount.toString(), Icons.pending, Colors.red),
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

  Widget _buildPledgeStatChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
            ],
          ),
        ],
      ),
    );
  }
}

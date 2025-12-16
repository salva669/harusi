import 'package:flutter/material.dart';
import '../models/wedding_analytics.dart';

class VendorStatusCard extends StatelessWidget {
  final WeddingAnalytics analytics;

  const VendorStatusCard({Key? key, required this.analytics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = analytics.totalVendors;
    final booked = analytics.vendorsBooked;
    final pending = total - booked;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vendor Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Total', total.toString(), Icons.business, Colors.blue),
                _buildStatColumn('Booked', booked.toString(), Icons.check_circle_outline, Colors.green),
                _buildStatColumn('Pending', pending.toString(), Icons.hourglass_empty, Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            _buildBudgetRow('Total Vendor Cost', analytics.totalVendorCost, Colors.purple),
            const SizedBox(height: 8),
            _buildBudgetRow('Avg Vendor Quote', analytics.averageVendorQuote, Colors.indigo),
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

  Widget _buildBudgetRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          'TZS ${amount.toStringAsFixed(2)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

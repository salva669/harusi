import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/wedding_analytics.dart';

class GuestAnalyticsCard extends StatelessWidget {
  final WeddingAnalytics analytics;

  const GuestAnalyticsCard({Key? key, required this.analytics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = analytics.totalInvitationsSent;
    final confirmed = analytics.totalConfirmed;
    final pending = analytics.totalPending;
    final declined = analytics.totalDeclined;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guest Analytics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Invited', total.toString(), Icons.mail, Colors.blue),
                _buildStatColumn('Confirmed', confirmed.toString(), Icons.check_circle, Colors.green),
                _buildStatColumn('Pending', pending.toString(), Icons.schedule, Colors.orange),
                _buildStatColumn('Declined', declined.toString(), Icons.cancel, Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: confirmed.toDouble(),
                      title: 'Confirmed\n$confirmed',
                      color: Colors.green,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: pending.toDouble(),
                      title: 'Pending\n$pending',
                      color: Colors.orange,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: declined.toDouble(),
                      title: 'Declined\n$declined',
                      color: Colors.red,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Avg guests per invitation: ${analytics.averageGuestsPerInvitation.toStringAsFixed(1)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
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
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

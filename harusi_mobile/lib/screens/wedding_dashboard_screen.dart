import 'package:flutter/material.dart';
import '../models/wedding_analytics.dart';
import '../models/pledge_summary.dart';
import '../services/api_service.dart';
import '../widgets/countdown_card.dart';
import '../widgets/health_scores_card.dart';
import '../widgets/guest_analytics_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/pledge_summary_card.dart';
import '../widgets/task_progress_card.dart';
import '../widgets/vendor_status_card.dart';
import '../widgets/budget_breakdown_card.dart';

class WeddingDashboardScreen extends StatefulWidget {
  final int weddingId;
  final ApiService apiService;

  const WeddingDashboardScreen({
    Key? key,
    required this.weddingId,
    required this.apiService,
  }) : super(key: key);

  @override
  State<WeddingDashboardScreen> createState() => _WeddingDashboardScreenState();
}

class _WeddingDashboardScreenState extends State<WeddingDashboardScreen> {
  WeddingAnalytics? analytics;
  PledgeSummary? pledgeSummary;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
       print('Fetching analytics for wedding ${widget.weddingId}...');
      
      // ✅ CORRECT: Call static methods directly on the class
      final analyticsData = await ApiService.getWeddingAnalytics(widget.weddingId);
      print('Analytics fetched successfully');
      
      final pledgeData = await ApiService.getPledgeSummary(widget.weddingId);
      print('Pledge summary fetched successfully');

      setState(() {
        analytics = analyticsData;
        pledgeSummary = pledgeData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wedding Dashboard'),
        backgroundColor: Colors.pink[400],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CountdownCard(analytics: analytics!),
                        const SizedBox(height: 16),
                        HealthScoresCard(analytics: analytics!),
                        const SizedBox(height: 16),
                        GuestAnalyticsCard(analytics: analytics!),
                        const SizedBox(height: 16),
                        BudgetCard(analytics: analytics!),
                        const SizedBox(height: 16),
                        if (pledgeSummary != null) ...[
                          PledgeSummaryCard(pledgeSummary: pledgeSummary!),
                          const SizedBox(height: 16),
                        ],
                        TaskProgressCard(analytics: analytics!),
                        const SizedBox(height: 16),
                        VendorStatusCard(analytics: analytics!),
                        const SizedBox(height: 16),
                        BudgetBreakdownCard(analytics: analytics!),
                      ],
                    ),
                  ),
                ),
    );
  }
}
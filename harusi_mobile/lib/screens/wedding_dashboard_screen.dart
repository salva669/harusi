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

  // ✅ ONLY weddingId parameter - NO apiService parameter
  const WeddingDashboardScreen({
    Key? key,
    required this.weddingId,
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

  /// Fetch analytics data from the API
  /// All ApiService methods are STATIC, so call them directly on the class
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
      print('Dashboard error: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: fetchData,
            ),
          ),
        );
      }
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
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading dashboard...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: fetchData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (analytics == null) {
      return const Center(
        child: Text('No analytics data available'),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Countdown Card
            CountdownCard(analytics: analytics!),
            const SizedBox(height: 16),

            // Health Scores
            HealthScoresCard(analytics: analytics!),
            const SizedBox(height: 16),

            // Guest Analytics
            GuestAnalyticsCard(analytics: analytics!),
            const SizedBox(height: 16),

            // Budget Overview
            BudgetCard(analytics: analytics!),
            const SizedBox(height: 16),

            // Pledge Summary (if available)
            if (pledgeSummary != null) ...[
              PledgeSummaryCard(pledgeSummary: pledgeSummary!),
              const SizedBox(height: 16),
            ],

            // Task Progress
            TaskProgressCard(analytics: analytics!),
            const SizedBox(height: 16),

            // Vendor Status
            VendorStatusCard(analytics: analytics!),
            const SizedBox(height: 16),

            // Budget Breakdown
            BudgetBreakdownCard(analytics: analytics!),
            
            // Bottom padding
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
class WeddingAnalytics {
  final int totalInvitationsSent;
  final int totalConfirmed;
  final int totalPending;
  final int totalDeclined;
  final double averageGuestsPerInvitation;
  final double totalEstimatedBudget;
  final double totalActualSpending;
  final double budgetVariance;
  final Map<String, dynamic> budgetCategoryBreakdown;
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final double completionPercentage;
  final int totalVendors;
  final int vendorsBooked;
  final double averageVendorQuote;
  final double totalVendorCost;
  final int daysUntilWedding;
  final int weeksUntilWedding;
  final double planningHealthScore;
  final double budgetHealthScore;
  final double taskHealthScore;
  final double guestHealthScore;
  final double overallHealthScore;

  WeddingAnalytics({
    required this.totalInvitationsSent,
    required this.totalConfirmed,
    required this.totalPending,
    required this.totalDeclined,
    required this.averageGuestsPerInvitation,
    required this.totalEstimatedBudget,
    required this.totalActualSpending,
    required this.budgetVariance,
    required this.budgetCategoryBreakdown,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.completionPercentage,
    required this.totalVendors,
    required this.vendorsBooked,
    required this.averageVendorQuote,
    required this.totalVendorCost,
    required this.daysUntilWedding,
    required this.weeksUntilWedding,
    required this.planningHealthScore,
    required this.budgetHealthScore,
    required this.taskHealthScore,
    required this.guestHealthScore,
    required this.overallHealthScore,
  });

  factory WeddingAnalytics.fromJson(Map<String, dynamic> json) {
    return WeddingAnalytics(
      totalInvitationsSent: json['total_invitations_sent'] ?? 0,
      totalConfirmed: json['total_confirmed'] ?? 0,
      totalPending: json['total_pending'] ?? 0,
      totalDeclined: json['total_declined'] ?? 0,
      averageGuestsPerInvitation: (json['average_guests_per_invitation'] ?? 1.0).toDouble(),
      totalEstimatedBudget: double.parse(json['total_estimated_budget']?.toString() ?? '0'),
      totalActualSpending: double.parse(json['total_actual_spending']?.toString() ?? '0'),
      budgetVariance: double.parse(json['budget_variance']?.toString() ?? '0'),
      budgetCategoryBreakdown: json['budget_category_breakdown'] ?? {},
      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
      pendingTasks: json['pending_tasks'] ?? 0,
      overdueTasks: json['overdue_tasks'] ?? 0,
      completionPercentage: (json['completion_percentage'] ?? 0.0).toDouble(),
      totalVendors: json['total_vendors'] ?? 0,
      vendorsBooked: json['vendors_booked'] ?? 0,
      averageVendorQuote: double.parse(json['average_vendor_quote']?.toString() ?? '0'),
      totalVendorCost: double.parse(json['total_vendor_cost']?.toString() ?? '0'),
      daysUntilWedding: json['days_until_wedding'] ?? 0,
      weeksUntilWedding: json['weeks_until_wedding'] ?? 0,
      planningHealthScore: (json['planning_health_score'] ?? 0.0).toDouble(),
      budgetHealthScore: (json['budget_health_score'] ?? 0.0).toDouble(),
      taskHealthScore: (json['task_health_score'] ?? 0.0).toDouble(),
      guestHealthScore: (json['guest_health_score'] ?? 0.0).toDouble(),
      overallHealthScore: (json['overall_health_score'] ?? 0.0).toDouble(),
    );
  }
}
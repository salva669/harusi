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
  // Helper function to handle any weirdness from the API
  double asDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0; // If it's a Map or List, return 0 instead of crashing
  }

  return WeddingAnalytics(
    totalInvitationsSent: json['total_invitations_sent'] ?? 0,
    totalConfirmed: json['total_confirmed'] ?? 0,
    totalPending: json['total_pending'] ?? 0,
    totalDeclined: json['total_declined'] ?? 0,
    averageGuestsPerInvitation: asDouble(json['average_guests_per_invitation']),
    totalEstimatedBudget: asDouble(json['total_estimated_budget']),
    totalActualSpending: asDouble(json['total_actual_spending']),
    budgetVariance: asDouble(json['budget_variance']),
    budgetCategoryBreakdown: json['budget_category_breakdown'] is Map 
        ? Map<String, dynamic>.from(json['budget_category_breakdown']) 
        : {},
    totalTasks: json['total_tasks'] ?? 0,
    completedTasks: json['completed_tasks'] ?? 0,
    pendingTasks: json['pending_tasks'] ?? 0,
    overdueTasks: json['overdue_tasks'] ?? 0,
    completionPercentage: asDouble(json['completion_percentage']),
    totalVendors: json['total_vendors'] ?? 0,
    vendorsBooked: json['vendors_booked'] ?? 0,
    averageVendorQuote: asDouble(json['average_vendor_quote']),
    totalVendorCost: asDouble(json['total_vendor_cost']),
    daysUntilWedding: json['days_until_wedding'] ?? 0,
    weeksUntilWedding: json['weeks_until_wedding'] ?? 0,
    planningHealthScore: asDouble(json['planning_health_score']),
    budgetHealthScore: asDouble(json['budget_health_score']),
    taskHealthScore: asDouble(json['task_health_score']),
    guestHealthScore: asDouble(json['guest_health_score']),
    overallHealthScore: asDouble(json['overall_health_score']),
  );
}
}
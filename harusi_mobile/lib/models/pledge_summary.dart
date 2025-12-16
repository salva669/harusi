class PledgeSummary {
  final double totalPledged;
  final double totalPaid;
  final double totalBalance;
  final int totalPledgers;
  final int fullyPaidCount;
  final int partiallyPaidCount;
  final int unpaidCount;

  PledgeSummary({
    required this.totalPledged,
    required this.totalPaid,
    required this.totalBalance,
    required this.totalPledgers,
    required this.fullyPaidCount,
    required this.partiallyPaidCount,
    required this.unpaidCount,
  });

  factory PledgeSummary.fromJson(Map<String, dynamic> json) {
    return PledgeSummary(
      totalPledged: double.parse(json['total_pledged']?.toString() ?? '0'),
      totalPaid: double.parse(json['total_paid']?.toString() ?? '0'),
      totalBalance: double.parse(json['total_balance']?.toString() ?? '0'),
      totalPledgers: json['total_pledgers'] ?? 0,
      fullyPaidCount: json['fully_paid_count'] ?? 0,
      partiallyPaidCount: json['partially_paid_count'] ?? 0,
      unpaidCount: json['unpaid_count'] ?? 0,
    );
  }
}
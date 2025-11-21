class Pledge {
  final int id;
  final int guestId;
  final String guestName;
  final String paymentStatus;
  final String? paymentMethod;
  final String? notes;
  final double pledgedAmount;
  final double paidAmount;
  final double balance;
  final DateTime? paymentDeadline;
  final DateTime createdAt;

  Pledge({
    required this.id,
    required this.guestId,
    required this.guestName,
    required this.paymentStatus,
    this.paymentMethod,
    this.notes,
    required this.pledgedAmount,
    required this.paidAmount,
    required this.balance,
    this.paymentDeadline,
    required this.createdAt,
  });

  factory Pledge.fromJson(Map<String, dynamic> json) {
    return Pledge(
      id: json['id'], 
      guestId: json['guest'], 
      guestName: json['guest_name'], 
      paymentStatus: json['payment_status'], 
      paymentMethod: json['payment_method'],
      notes: json['notes'],
      pledgedAmount: double.parse(json['pledged_amount'].toString()), 
      paidAmount: double.parse(json['paid_amount'].toString()), 
      balance: double.parse(json['balance'].toString()), 
      paymentDeadline: json['payment_deadline'] != null
        ? DateTime.parse(json['payment_deadline'])
        : null,
      createdAt: DateTime.parse(json['created_at']),
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'guest': guestId,
      'pledged_amount': pledgedAmount,
      'paid_amount': paidAmount,
      'payment_method': paymentMethod,
      'payment_deadline': paymentDeadline?.toIso8601String().split('T')[0],
      'notes': notes,
    };
  }

  double get paymentProgress {
    if (pledgedAmount == 0) return 0;
    return (paidAmount / pledgedAmount) * 100;
  }
}
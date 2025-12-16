class GuestPledge {
  final int? id;
  final int guestId;
  final int weddingId;
  final double pledgedAmount;
  final double paidAmount;
  final double balance;
  final String paymentStatus;
  final String? paymentMethod;
  final DateTime pledgeDate;
  final DateTime? paymentDeadline;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GuestPledge({
    this.id,
    required this.guestId,
    required this.weddingId,
    required this.pledgedAmount,
    this.paidAmount = 0,
    this.balance = 0,
    this.paymentStatus = 'pledged',
    this.paymentMethod,
    required this.pledgeDate,
    this.paymentDeadline,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory GuestPledge.fromJson(Map<String, dynamic> json) {
    return GuestPledge(
      id: json['id'],
      guestId: json['guest'],
      weddingId: json['wedding'],
      pledgedAmount: double.parse(json['pledged_amount'].toString()),
      paidAmount: double.parse(json['paid_amount'].toString()),
      balance: double.parse(json['balance'].toString()),
      paymentStatus: json['payment_status'] ?? 'pledged',
      paymentMethod: json['payment_method'],
      pledgeDate: DateTime.parse(json['pledge_date']),
      paymentDeadline: json['payment_deadline'] != null ? DateTime.parse(json['payment_deadline']) : null,
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'guest': guestId,
      'wedding': weddingId,
      'pledged_amount': pledgedAmount,
      'paid_amount': paidAmount,
    };
    
    // Only add optional fields if they have values
    if (paymentMethod != null && paymentMethod!.isNotEmpty) {
      json['payment_method'] = paymentMethod;
    }
    
    if (paymentDeadline != null) {
      json['payment_deadline'] = paymentDeadline!.toIso8601String().split('T')[0];
    }
    
    if (notes != null && notes!.isNotEmpty) {
      json['notes'] = notes;
    }
    
    // DON'T send pledge_date - Django auto-generates it with auto_now_add=True
    
    return json;
  }
}
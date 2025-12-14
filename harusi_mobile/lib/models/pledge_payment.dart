class PledgePayment {
  final int? id;
  final int pledgeId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String? referenceNumber;
  final String? notes;
  final DateTime? createdAt;

  PledgePayment({
    this.id,
    required this.pledgeId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.referenceNumber,
    this.notes,
    this.createdAt,
  });

  factory PledgePayment.fromJson(Map<String, dynamic> json) {
    return PledgePayment(
      id: json['id'],
      pledgeId: json['pledge'],
      amount: double.parse(json['amount'].toString()),
      paymentDate: DateTime.parse(json['payment_date']),
      paymentMethod: json['payment_method'],
      referenceNumber: json['reference_number'],
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'pledge': pledgeId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'payment_method': paymentMethod,
    };
    
    if (referenceNumber != null && referenceNumber!.isNotEmpty) {
      json['reference_number'] = referenceNumber;
    }
    
    if (notes != null && notes!.isNotEmpty) {
      json['notes'] = notes;
    }
    
    return json;
  }
}
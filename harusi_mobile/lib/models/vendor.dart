class Vendor {
  final int? id;
  final int weddingId;
  final String vendorType;
  final String businessName;
  final String contactPerson;
  final String phone;
  final String? email;  // ← CHANGED: Made optional
  final String? website;
  final double? quote;
  final double? depositPaid;
  final double? finalAmount;
  final String status;
  final String? vendorNotes;
  final String? contractFile;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vendor({
    this.id,
    required this.weddingId,
    required this.vendorType,
    required this.businessName,
    required this.contactPerson,
    required this.phone,
    this.email,  // ← CHANGED: No longer required
    this.website,
    this.quote,
    this.depositPaid,
    this.finalAmount,
    this.status = 'inquiry',
    this.vendorNotes,
    this.contractFile,
    this.createdAt,
    this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      weddingId: json['wedding'],
      vendorType: json['vendor_type'],
      businessName: json['business_name'],
      contactPerson: json['contact_person'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      quote: json['quote'] != null ? double.parse(json['quote'].toString()) : null,
      depositPaid: json['deposit_paid'] != null ? double.parse(json['deposit_paid'].toString()) : null,
      finalAmount: json['final_amount'] != null ? double.parse(json['final_amount'].toString()) : null,
      status: json['status'] ?? 'inquiry',
      vendorNotes: json['vendor_notes'],
      contractFile: json['contract_file'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'wedding': weddingId,
      'vendor_type': vendorType,
      'business_name': businessName,
      'contact_person': contactPerson,
      'phone': phone,
      'status': status,
    };
    
    // Only include fields if they're not null/empty
    if (email != null && email!.isNotEmpty) map['email'] = email;
    if (website != null && website!.isNotEmpty) map['website'] = website;
    if (quote != null) map['quote'] = quote;
    if (depositPaid != null) map['deposit_paid'] = depositPaid;
    if (finalAmount != null) map['final_amount'] = finalAmount;
    if (vendorNotes != null && vendorNotes!.isNotEmpty) map['vendor_notes'] = vendorNotes;
    
    return map;
  }
}
class Budget {
  final int? id;
  final int weddingId;
  final String category;
  final String itemName;
  final double estimatedCost;
  final double? actualCost;
  final String? notes;
  final DateTime? createdAt;

  Budget({
    this.id,
    required this.weddingId,
    required this.category,
    required this.itemName,
    required this.estimatedCost,
    this.actualCost,
    this.notes,
    this.createdAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      weddingId: json['wedding'],
      category: json['category'],
      itemName: json['item_name'],
      estimatedCost: double.parse(json['estimated_cost'].toString()),
      actualCost: json['actual_cost'] != null ? double.parse(json['actual_cost'].toString()) : null,
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wedding': weddingId,
      'category': category,
      'item_name': itemName,
      'estimated_cost': estimatedCost,
      'actual_cost': actualCost,
      'notes': notes,
    };
  }
}
class Wedding {
  final int? id;
  final int userId;
  final String brideName;
  final String groomName;
  final DateTime weddingDate;
  final String venue;
  final double budget;
  final String status;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Wedding({
    this.id,
    required this.userId,
    required this.brideName,
    required this.groomName,
    required this.weddingDate,
    required this.venue,
    required this.budget,
    this.status = 'planning',
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Wedding.fromJson(Map<String, dynamic> json) {
    return Wedding(
      id: json['id'],
      userId: json['user'],
      brideName: json['bride_name'],
      groomName: json['groom_name'],
      weddingDate: DateTime.parse(json['wedding_date']),
      venue: json['venue'],
      budget: double.parse(json['budget'].toString()),
      status: json['status'] ?? 'planning',
      description: json['description'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'bride_name': brideName,
      'groom_name': groomName,
      'wedding_date': weddingDate.toIso8601String().split('T')[0],
      'venue': venue,
      'budget': budget,
      'status': status,
      'description': description,
    };
  }
}

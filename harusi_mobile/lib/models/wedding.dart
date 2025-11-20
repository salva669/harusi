class Wedding {
  final int id;
  final String brideName;
  final String groomName;
  final DateTime weddingDate;
  final String venue;
  final double budget;
  final String status;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wedding({
    required this.id,
    required this.brideName,
    required this.groomName,
    required this.weddingDate,
    required this.venue,
    required this.budget,
    required this.status,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wedding.fromJson(Map<String, dynamic> json) {
    return Wedding(
      id: json['id'],
      brideName: json['bride_name'], 
      groomName: json['groom_name'], 
      weddingDate: DateTime.parse(json['wedding_date']), 
      venue: json['venue'], 
      budget: double.parse(json['budget'].toString()), 
      status: json['status'], 
      createdAt: DateTime.parse(json['createdAt']), 
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bride_name': brideName,
      'groom_name': groomName,
      'wedding_date': weddingDate.toIso8601String().split('T')[0],
      'venue': venue,
      'budget': budget,
      'status': status,
      'description': description,
    };
  }

  String get coupleNames => '$brideName & $groomName';

  int get daysUntil {
    final now = DateTime.now();
    return weddingDate.difference(now).inDays;
  }
}
class Timeline {
  final int? id;
  final int weddingId;
  final String eventType;
  final String title;
  final String? description;
  final DateTime date;
  final String? time;
  final String? location;
  final bool isCompleted;
  final DateTime? createdAt;

  Timeline({
    this.id,
    required this.weddingId,
    required this.eventType,
    required this.title,
    this.description,
    required this.date,
    this.time,
    this.location,
    this.isCompleted = false,
    this.createdAt,
  });

  factory Timeline.fromJson(Map<String, dynamic> json) {
    return Timeline(
      id: json['id'],
      weddingId: json['wedding'],
      eventType: json['event_type'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      location: json['location'],
      isCompleted: json['is_completed'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wedding': weddingId,
      'event_type': eventType,
      'title': title,
      'description': description,
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'location': location,
      'is_completed': isCompleted,
    };
  }
}
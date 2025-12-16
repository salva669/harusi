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
    final map = <String, dynamic>{
      'event_type': eventType,
      'title': title,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'is_completed': isCompleted,
    };
    
    // Only include wedding_id when creating (not updating)
    if (id == null) {
      map['wedding'] = weddingId;
    }
    
    // Only include optional fields if they have values
    if (description != null && description!.isNotEmpty) {
      map['description'] = description;
    }
    if (time != null && time!.isNotEmpty) {
      map['time'] = time;
    }
    if (location != null && location!.isNotEmpty) {
      map['location'] = location;
    }
    
    return map;
  }

  // Create a copy with updated fields
  Timeline copyWith({
    int? id,
    int? weddingId,
    String? eventType,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Timeline(
      id: id ?? this.id,
      weddingId: weddingId ?? this.weddingId,
      eventType: eventType ?? this.eventType,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
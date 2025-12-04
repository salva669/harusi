class Task {
  final int? id;
  final int weddingId;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final DateTime? dueDate;
  final String? assignedTo;
  final double? cost;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    this.id,
    required this.weddingId,
    required this.title,
    this.description,
    this.priority = 'medium',
    this.status = 'todo',
    this.dueDate,
    this.assignedTo,
    this.cost,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      weddingId: json['wedding'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'todo',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      assignedTo: json['assigned_to'],
      cost: json['cost'] != null ? double.parse(json['cost'].toString()) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wedding': weddingId,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'assigned_to': assignedTo,
      'cost': cost,
    };
  }
}

class Guest {
  final int? id;
  final int weddingId;
  final String name;
  final String? phone;
  final String? email;
  final String relationship;
  final String rsvpStatus;
  final int numberOfGuests;
  final String? dietaryRestrictions;
  final DateTime? createdAt;

  Guest({
    this.id,
    required this.weddingId,
    required this.name,
    this.phone,
    this.email,
    required this.relationship,
    this.rsvpStatus = 'pending',
    this.numberOfGuests = 1,
    this.dietaryRestrictions,
    this.createdAt,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      weddingId: json['wedding'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      relationship: json['relationship'],
      rsvpStatus: json['rsvp_status'] ?? 'pending',
      numberOfGuests: json['number_of_guests'] ?? 1,
      dietaryRestrictions: json['dietary_restrictions'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wedding': weddingId,
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
      'rsvp_status': rsvpStatus,
      'number_of_guests': numberOfGuests,
      'dietary_restrictions': dietaryRestrictions,
    };
  }
}

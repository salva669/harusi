class Guest {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String relationship;
  final String rsvpStatus;
  final int numberOfGuests;
  final String? dietaryRestrictions;
  final DateTime createdAt;

  Guest({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.relationship,
    required this.rsvpStatus,
    required this.numberOfGuests,
    this.dietaryRestrictions,
    required this.createdAt,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'], 
      name: json['name'], 
      relationship: json['relationship'], 
      rsvpStatus: json['rsvp_status'], 
      numberOfGuests: json['number_of_guests'], 
      email: json['email'],
      phone: json['phone'],
      dietaryRestrictions: json['dietary_restrictions'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'relationship': relationship,
      'rsvp_status': rsvpStatus,
      'number_of_guests': numberOfGuests,
      'dietary_restrictions': dietaryRestrictions,
    };
  }
}
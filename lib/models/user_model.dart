class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? location;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.location,
    required this.createdAt,
  });

  // Create User from Firestore document
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      location: json['location'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert User to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create empty/default user
  factory User.empty() {
    return User(
      id: '',
      email: '',
      name: 'কৃষক',
      phone: null,
      location: null,
      createdAt: DateTime.now(),
    );
  }

  // CopyWith method for easy updates
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? location,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

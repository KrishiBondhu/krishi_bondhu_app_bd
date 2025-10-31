import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? location; // Kept for legacy
  final String? district;
  final String? upazila;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.location,
    this.district,
    this.upazila,
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
      district: json['district'], // Added
      upazila: json['upazila'], // Added
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate() // Corrected parsing
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
      'district': district, // Added
      'upazila': upazila, // Added
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
      district: null,
      upazila: null,
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
    String? district,
    String? upazila,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      district: district ?? this.district, // Added
      upazila: upazila ?? this.upazila, // Added
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? district;
  final String? upazila;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.district,
    this.upazila,
    this.createdAt,
  });

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    final Timestamp? createdAtTimestamp = data['createdAt'] as Timestamp?;

    return User(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'],
      district: data['district'],
      upazila: data['upazila'],
      createdAt: createdAtTimestamp?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'district': district,
      'upazila': upazila,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? district,
    String? upazila,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

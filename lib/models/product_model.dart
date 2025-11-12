import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String productName;
  final String category;
  final double pricePerUnit;
  final String unit;
  final String availableQuantity;
  final List<String>
      imageUrls; // <-- ⚠️ This is the main change (was String imageUrl)
  final String sellerId;
  final String sellerName;
  final String? sellerPhone;
  final String? sellerDistrict;
  final String? sellerUpazila;
  final Timestamp createdAt;

  Product({
    this.id,
    required this.productName,
    required this.category,
    required this.pricePerUnit,
    required this.unit,
    required this.availableQuantity,
    required this.imageUrls, // <-- ⚠️ Updated
    required this.sellerId,
    required this.sellerName,
    this.sellerPhone,
    this.sellerDistrict,
    this.sellerUpazila,
    required this.createdAt,
  });

  // Convert to JSON (for sending to Firestore)
  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'category': category,
      'pricePerUnit': pricePerUnit,
      'unit': unit,
      'availableQuantity': availableQuantity,
      'imageUrls': imageUrls, // <-- ⚠️ Updated
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'sellerDistrict': sellerDistrict,
      'sellerUpazila': sellerUpazila,
      'createdAt': createdAt,
    };
  }

  // Create from JSON (for reading from Firestore)
  factory Product.fromJson(Map<String, dynamic> json, String id) {
    // Handle if imageUrls is missing or is an old single string
    List<String> images = [];
    if (json['imageUrls'] is List) {
      images = List<String>.from(json['imageUrls']);
    } else if (json['imageUrl'] is String) {
      // Handle old data
      images = [json['imageUrl']];
    }

    return Product(
      id: id,
      productName: json['productName'],
      category: json['category'],
      pricePerUnit: (json['pricePerUnit'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? 'পিস',
      availableQuantity: json['availableQuantity'] ?? 'N/A',
      imageUrls: images, // <-- ⚠️ Updated
      sellerId: json['sellerId'],
      sellerName: json['sellerName'],
      sellerPhone: json['sellerPhone'],
      sellerDistrict: json['sellerDistrict'],
      sellerUpazila: json['sellerUpazila'],
      createdAt: json['createdAt'] as Timestamp,
    );
  }
}

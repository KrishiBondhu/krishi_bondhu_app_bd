import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:krishi_bondhu_app_bd/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  /// Create a new product listing
  Future<void> createProduct(Product product) async {
    try {
      await _firestore.collection(_collection).add(product.toJson());
    } catch (e) {
      throw Exception('Failed to create product listing: $e');
    }
  }

  /// Update an existing product
  Future<void> updateProduct(
      String productId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(productId).update(data);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Get all products (for the marketplace)
  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get products for a specific user (for "My Listings")
  Stream<List<Product>> getProductsForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get a single product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(productId).get();
      if (doc.exists && doc.data() != null) {
        return Product.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  /// Delete a product
  Future<void> deleteProduct(Product product) async {
    if (product.id == null || product.id!.isEmpty) {
      throw Exception('Product ID is null or empty');
    }

    try {
      // Delete from Firestore
      await _firestore.collection(_collection).doc(product.id).delete();

      // Note: ImgBB free API doesn't support image deletion
      // Images will remain on ImgBB but won't be linked to any product
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Search products by name
  Stream<List<Product>> searchProducts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _firestore
        .collection(_collection)
        .orderBy('productName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .where((product) =>
              product.productName.toLowerCase().contains(lowercaseQuery))
          .toList();
    });
  }

  /// Get products by location (district)
  Stream<List<Product>> getProductsByDistrict(String district) {
    return _firestore
        .collection(_collection)
        .where('sellerDistrict', isEqualTo: district)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
    });
  }
}

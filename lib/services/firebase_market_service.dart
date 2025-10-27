import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market_price.dart';

class FirebaseMarketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'market_prices';

  /// Get all market prices from Firebase (Real-time stream)
  Stream<List<MarketPrice>> getMarketPrices() {
    return _firestore
        .collection(_collection)
        .orderBy('cropName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MarketPrice.fromJson(data);
      }).toList();
    });
  }

  /// Get market prices by category (Real-time stream)
  Stream<List<MarketPrice>> getMarketPricesByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('cropName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MarketPrice.fromJson(data);
      }).toList();
    });
  }

  /// Search market prices by crop name
  Stream<List<MarketPrice>> searchMarketPrices(String query) {
    return _firestore
        .collection(_collection)
        .where('cropName', isGreaterThanOrEqualTo: query)
        .where('cropName', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MarketPrice.fromJson(data);
      }).toList();
    });
  }

  /// Add a new market price
  Future<void> addMarketPrice(Map<String, dynamic> priceData) async {
    await _firestore.collection(_collection).add(priceData);
  }

  /// Update market price
  Future<void> updateMarketPrice(
      String id, Map<String, dynamic> priceData) async {
    await _firestore.collection(_collection).doc(id).update(priceData);
  }

  /// Delete market price
  Future<void> deleteMarketPrice(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}

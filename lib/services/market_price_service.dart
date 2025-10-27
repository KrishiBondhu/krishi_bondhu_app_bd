import '../models/market_price.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MarketPriceService {
  static final MarketPriceService _instance = MarketPriceService._internal();
  factory MarketPriceService() => _instance;
  MarketPriceService._internal();

  static const String _favoritesKey = 'favorite_crops';
  static const String _alertsKey = 'price_alerts';

  Future<List<MarketPrice>> getAllPrices() async {
    await Future.delayed(const Duration(seconds: 1));
    return _getMockPrices();
  }

  Future<List<MarketPrice>> getPricesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allPrices = await getAllPrices();
    return allPrices.where((price) => price.category == category).toList();
  }

  Future<List<MarketPrice>> searchPrices(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allPrices = await getAllPrices();
    return allPrices
        .where((price) =>
            price.cropName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<List<MarketPrice>> getTrendingPrices() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allPrices = await getAllPrices();
    final withPrevious =
        allPrices.where((p) => p.previousPrice != null).toList();

    withPrevious.sort((a, b) {
      final aChange = (a.priceChangePercentage ?? 0).abs();
      final bChange = (b.priceChangePercentage ?? 0).abs();
      return bChange.compareTo(aChange);
    });

    return withPrevious.take(5).toList();
  }

  Future<MarketPrice?> getPriceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allPrices = await getAllPrices();
    try {
      return allPrices.firstWhere((price) => price.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<PriceHistory>> getPriceHistory(String cropId,
      {int days = 30}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    const basePrice = 50.0;
    return List.generate(days, (index) {
      final date = now.subtract(Duration(days: days - 1 - index));
      final variance = (index % 5 - 2) * 5.0;
      return PriceHistory(
        date: date,
        price: basePrice + variance + (index * 0.5),
      );
    });
  }

  Future<Map<String, List<MarketPrice>>> compareMarketsForCrop(
      String cropName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allPrices = await getAllPrices();
    final cropPrices = allPrices.where((p) => p.cropName == cropName).toList();

    final Map<String, List<MarketPrice>> marketMap = {};
    for (var price in cropPrices) {
      if (!marketMap.containsKey(price.market)) {
        marketMap[price.market] = [];
      }
      marketMap[price.market]!.add(price);
    }
    return marketMap;
  }

  Future<List<String>> getFavoriteCropIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson == null) return [];

    final List<dynamic> favorites = json.decode(favoritesJson);
    return favorites.cast<String>();
  }

  Future<bool> addToFavorites(String cropId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteCropIds();

    if (!favorites.contains(cropId)) {
      favorites.add(cropId);
      await prefs.setString(_favoritesKey, json.encode(favorites));
      return true;
    }
    return false;
  }

  Future<bool> removeFromFavorites(String cropId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteCropIds();

    if (favorites.contains(cropId)) {
      favorites.remove(cropId);
      await prefs.setString(_favoritesKey, json.encode(favorites));
      return true;
    }
    return false;
  }

  Future<bool> isFavorite(String cropId) async {
    final favorites = await getFavoriteCropIds();
    return favorites.contains(cropId);
  }

  Future<List<MarketPrice>> getFavoriteCrops() async {
    final favoriteIds = await getFavoriteCropIds();
    final allPrices = await getAllPrices();
    return allPrices.where((price) => favoriteIds.contains(price.id)).toList();
  }

  Future<List<PriceAlert>> getAllAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    final alertsJson = prefs.getString(_alertsKey);
    if (alertsJson == null) return [];

    final List<dynamic> alerts = json.decode(alertsJson);
    return alerts.map((e) => PriceAlert.fromJson(e)).toList();
  }

  Future<bool> addPriceAlert(PriceAlert alert) async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = await getAllAlerts();

    alerts.add(alert);
    await prefs.setString(
        _alertsKey, json.encode(alerts.map((e) => e.toJson()).toList()));
    return true;
  }

  Future<bool> removePriceAlert(String alertId) async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = await getAllAlerts();

    alerts.removeWhere((alert) => alert.id == alertId);
    await prefs.setString(
        _alertsKey, json.encode(alerts.map((e) => e.toJson()).toList()));
    return true;
  }

  Future<bool> toggleAlert(String alertId) async {
    final prefs = await SharedPreferences.getInstance();
    final alerts = await getAllAlerts();

    final index = alerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      final alert = alerts[index];
      alerts[index] = PriceAlert(
        id: alert.id,
        cropId: alert.cropId,
        cropName: alert.cropName,
        targetPrice: alert.targetPrice,
        condition: alert.condition,
        isActive: !alert.isActive,
        createdAt: alert.createdAt,
      );
      await prefs.setString(
          _alertsKey, json.encode(alerts.map((e) => e.toJson()).toList()));
      return true;
    }
    return false;
  }

  List<MarketPrice> _getMockPrices() {
    return [
      // VEGETABLES
      MarketPrice(
        id: '1',
        cropName: 'Potato',
        category: 'Vegetables',
        price: 25.50,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 23.00,
        description: 'Fresh potatoes from local farms',
        minPrice: 22.00,
        maxPrice: 28.00,
        avgPrice: 25.00,
      ),
      MarketPrice(
        id: '2',
        cropName: 'Tomato',
        category: 'Vegetables',
        price: 60.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 65.00,
        description: 'Ripe red tomatoes',
        minPrice: 55.00,
        maxPrice: 70.00,
        avgPrice: 60.00,
      ),
      MarketPrice(
        id: '3',
        cropName: 'Onion',
        category: 'Vegetables',
        price: 45.00,
        unit: 'kg',
        market: 'Chittagong - Chaktai',
        date: DateTime.now(),
        previousPrice: 42.00,
        description: 'Golden onions',
        minPrice: 40.00,
        maxPrice: 48.00,
        avgPrice: 44.00,
      ),
      MarketPrice(
        id: '4',
        cropName: 'Cabbage',
        category: 'Vegetables',
        price: 20.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 22.00,
        description: 'Fresh green cabbage',
        minPrice: 18.00,
        maxPrice: 25.00,
        avgPrice: 20.50,
      ),
      MarketPrice(
        id: '5',
        cropName: 'Cauliflower',
        category: 'Vegetables',
        price: 30.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 28.00,
        description: 'White cauliflower',
        minPrice: 25.00,
        maxPrice: 35.00,
        avgPrice: 30.00,
      ),
      MarketPrice(
        id: '6',
        cropName: 'Eggplant',
        category: 'Vegetables',
        price: 35.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 38.00,
        description: 'Purple eggplant',
        minPrice: 30.00,
        maxPrice: 40.00,
        avgPrice: 35.00,
      ),
      MarketPrice(
        id: '7',
        cropName: 'Carrot',
        category: 'Vegetables',
        price: 32.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 30.00,
        description: 'Orange carrots',
        minPrice: 28.00,
        maxPrice: 36.00,
        avgPrice: 32.00,
      ),
      MarketPrice(
        id: '8',
        cropName: 'Cucumber',
        category: 'Vegetables',
        price: 28.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 25.00,
        description: 'Fresh cucumbers',
        minPrice: 24.00,
        maxPrice: 32.00,
        avgPrice: 28.00,
      ),
      MarketPrice(
        id: '9',
        cropName: 'Bell Pepper',
        category: 'Vegetables',
        price: 55.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 52.00,
        description: 'Colorful bell peppers',
        minPrice: 50.00,
        maxPrice: 60.00,
        avgPrice: 55.00,
      ),
      MarketPrice(
        id: '10',
        cropName: 'Spinach',
        category: 'Vegetables',
        price: 40.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 38.00,
        description: 'Fresh green spinach',
        minPrice: 35.00,
        maxPrice: 45.00,
        avgPrice: 40.00,
      ),

      // FRUITS
      MarketPrice(
        id: '11',
        cropName: 'Mango',
        category: 'Fruits',
        price: 120.00,
        unit: 'kg',
        market: 'Rajshahi - Shah Makhdum',
        date: DateTime.now(),
        previousPrice: 110.00,
        description: 'Sweet mangoes',
        minPrice: 100.00,
        maxPrice: 150.00,
        avgPrice: 120.00,
      ),
      MarketPrice(
        id: '12',
        cropName: 'Banana',
        category: 'Fruits',
        price: 40.00,
        unit: 'dozen',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 45.00,
        description: 'Yellow bananas',
        minPrice: 35.00,
        maxPrice: 50.00,
        avgPrice: 40.00,
      ),
      MarketPrice(
        id: '13',
        cropName: 'Papaya',
        category: 'Fruits',
        price: 25.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 25.00,
        description: 'Orange papayas',
        minPrice: 20.00,
        maxPrice: 30.00,
        avgPrice: 25.00,
      ),
      MarketPrice(
        id: '14',
        cropName: 'Guava',
        category: 'Fruits',
        price: 50.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 48.00,
        description: 'Fresh guavas',
        minPrice: 45.00,
        maxPrice: 55.00,
        avgPrice: 50.00,
      ),
      MarketPrice(
        id: '15',
        cropName: 'Pineapple',
        category: 'Fruits',
        price: 35.00,
        unit: 'piece',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 32.00,
        description: 'Golden pineapples',
        minPrice: 30.00,
        maxPrice: 40.00,
        avgPrice: 35.00,
      ),
      MarketPrice(
        id: '16',
        cropName: 'Watermelon',
        category: 'Fruits',
        price: 15.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 14.00,
        description: 'Sweet watermelons',
        minPrice: 12.00,
        maxPrice: 18.00,
        avgPrice: 15.00,
      ),
      MarketPrice(
        id: '17',
        cropName: 'Orange',
        category: 'Fruits',
        price: 45.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 42.00,
        description: 'Juicy oranges',
        minPrice: 40.00,
        maxPrice: 50.00,
        avgPrice: 45.00,
      ),
      MarketPrice(
        id: '18',
        cropName: 'Pomegranate',
        category: 'Fruits',
        price: 80.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 75.00,
        description: 'Red pomegranates',
        minPrice: 70.00,
        maxPrice: 90.00,
        avgPrice: 80.00,
      ),

      // GRAINS
      MarketPrice(
        id: '19',
        cropName: 'Rice (BR-28)',
        category: 'Grains',
        price: 55.00,
        unit: 'kg',
        market: 'Dhaka - Badamtoli',
        date: DateTime.now(),
        previousPrice: 52.00,
        description: 'Medium grain rice',
        minPrice: 50.00,
        maxPrice: 60.00,
        avgPrice: 55.00,
      ),
      MarketPrice(
        id: '20',
        cropName: 'Rice (Basmati)',
        category: 'Grains',
        price: 85.00,
        unit: 'kg',
        market: 'Dhaka - Badamtoli',
        date: DateTime.now(),
        previousPrice: 80.00,
        description: 'Premium basmati rice',
        minPrice: 75.00,
        maxPrice: 95.00,
        avgPrice: 85.00,
      ),
      MarketPrice(
        id: '21',
        cropName: 'Wheat',
        category: 'Grains',
        price: 38.00,
        unit: 'kg',
        market: 'Dhaka - Badamtoli',
        date: DateTime.now(),
        previousPrice: 38.00,
        description: 'Wheat flour',
        minPrice: 35.00,
        maxPrice: 42.00,
        avgPrice: 38.00,
      ),
      MarketPrice(
        id: '22',
        cropName: 'Corn',
        category: 'Grains',
        price: 32.00,
        unit: 'kg',
        market: 'Dhaka - Badamtoli',
        date: DateTime.now(),
        previousPrice: 30.00,
        description: 'Yellow corn',
        minPrice: 28.00,
        maxPrice: 35.00,
        avgPrice: 32.00,
      ),
      MarketPrice(
        id: '23',
        cropName: 'Maize',
        category: 'Grains',
        price: 28.00,
        unit: 'kg',
        market: 'Dhaka - Badamtoli',
        date: DateTime.now(),
        previousPrice: 26.00,
        description: 'Corn grain',
        minPrice: 25.00,
        maxPrice: 31.00,
        avgPrice: 28.00,
      ),
      MarketPrice(
        id: '24',
        cropName: 'Barley',
        category: 'Grains',
        price: 35.00,
        unit: 'kg',
        market: 'Dhaka - Badamtoli',
        date: DateTime.now(),
        previousPrice: 33.00,
        description: 'Barley grain',
        minPrice: 32.00,
        maxPrice: 38.00,
        avgPrice: 35.00,
      ),

      // PULSES
      MarketPrice(
        id: '25',
        cropName: 'Lentil (Red)',
        category: 'Pulses',
        price: 110.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 105.00,
        description: 'Red lentils',
        minPrice: 100.00,
        maxPrice: 120.00,
        avgPrice: 110.00,
      ),
      MarketPrice(
        id: '26',
        cropName: 'Lentil (Green)',
        category: 'Pulses',
        price: 125.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 120.00,
        description: 'Green lentils',
        minPrice: 115.00,
        maxPrice: 135.00,
        avgPrice: 125.00,
      ),
      MarketPrice(
        id: '27',
        cropName: 'Chickpea',
        category: 'Pulses',
        price: 95.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 98.00,
        description: 'Chickpeas',
        minPrice: 90.00,
        maxPrice: 105.00,
        avgPrice: 95.00,
      ),
      MarketPrice(
        id: '28',
        cropName: 'Black Gram',
        category: 'Pulses',
        price: 120.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 115.00,
        description: 'Black gram',
        minPrice: 110.00,
        maxPrice: 130.00,
        avgPrice: 120.00,
      ),
      MarketPrice(
        id: '29',
        cropName: 'Peas (Green)',
        category: 'Pulses',
        price: 85.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 82.00,
        description: 'Green peas',
        minPrice: 78.00,
        maxPrice: 92.00,
        avgPrice: 85.00,
      ),
      MarketPrice(
        id: '30',
        cropName: 'Moong Dal',
        category: 'Pulses',
        price: 105.00,
        unit: 'kg',
        market: 'Dhaka - Karwan Bazar',
        date: DateTime.now(),
        previousPrice: 100.00,
        description: 'Moong beans',
        minPrice: 95.00,
        maxPrice: 115.00,
        avgPrice: 105.00,
      ),

      // SPICES
      MarketPrice(
        id: '31',
        cropName: 'Chili (Red)',
        category: 'Spices',
        price: 180.00,
        unit: 'kg',
        market: 'Dhaka - Spice Market',
        date: DateTime.now(),
        previousPrice: 175.00,
        description: 'Red chili peppers',
        minPrice: 170.00,
        maxPrice: 200.00,
        avgPrice: 180.00,
      ),
      MarketPrice(
        id: '32',
        cropName: 'Turmeric',
        category: 'Spices',
        price: 95.00,
        unit: 'kg',
        market: 'Dhaka - Spice Market',
        date: DateTime.now(),
        previousPrice: 92.00,
        description: 'Turmeric powder',
        minPrice: 85.00,
        maxPrice: 105.00,
        avgPrice: 95.00,
      ),
      MarketPrice(
        id: '33',
        cropName: 'Cumin',
        category: 'Spices',
        price: 250.00,
        unit: 'kg',
        market: 'Dhaka - Spice Market',
        date: DateTime.now(),
        previousPrice: 245.00,
        description: 'Cumin seeds',
        minPrice: 240.00,
        maxPrice: 270.00,
        avgPrice: 250.00,
      ),
      MarketPrice(
        id: '34',
        cropName: 'Garlic',
        category: 'Spices',
        price: 75.00,
        unit: 'kg',
        market: 'Dhaka - Spice Market',
        date: DateTime.now(),
        previousPrice: 72.00,
        description: 'Fresh garlic',
        minPrice: 68.00,
        maxPrice: 85.00,
        avgPrice: 75.00,
      ),
      MarketPrice(
        id: '35',
        cropName: 'Ginger',
        category: 'Spices',
        price: 65.00,
        unit: 'kg',
        market: 'Dhaka - Spice Market',
        date: DateTime.now(),
        previousPrice: 62.00,
        description: 'Fresh ginger',
        minPrice: 58.00,
        maxPrice: 72.00,
        avgPrice: 65.00,
      ),

      // CASH CROPS
      MarketPrice(
        id: '36',
        cropName: 'Tea',
        category: 'Cash Crops',
        price: 450.00,
        unit: 'kg',
        market: 'Sylhet - Tea Market',
        date: DateTime.now(),
        previousPrice: 440.00,
        description: 'Premium tea leaves',
        minPrice: 420.00,
        maxPrice: 480.00,
        avgPrice: 450.00,
      ),
      MarketPrice(
        id: '37',
        cropName: 'Cotton',
        category: 'Cash Crops',
        price: 5200.00,
        unit: 'quintal',
        market: 'Dhaka - Cotton Market',
        date: DateTime.now(),
        previousPrice: 5000.00,
        description: 'Raw cotton',
        minPrice: 4800.00,
        maxPrice: 5500.00,
        avgPrice: 5200.00,
      ),
      MarketPrice(
        id: '38',
        cropName: 'Jute',
        category: 'Cash Crops',
        price: 3800.00,
        unit: 'quintal',
        market: 'Dhaka - Jute Market',
        date: DateTime.now(),
        previousPrice: 3700.00,
        description: 'Raw jute fiber',
        minPrice: 3500.00,
        maxPrice: 4100.00,
        avgPrice: 3800.00,
      ),
      MarketPrice(
        id: '39',
        cropName: 'Sugarcane',
        category: 'Cash Crops',
        price: 380.00,
        unit: 'quintal',
        market: 'Khulna - Sugar Market',
        date: DateTime.now(),
        previousPrice: 370.00,
        description: 'Fresh sugarcane',
        minPrice: 350.00,
        maxPrice: 420.00,
        avgPrice: 380.00,
      ),
      MarketPrice(
        id: '40',
        cropName: 'Coconut',
        category: 'Cash Crops',
        price: 28.00,
        unit: 'piece',
        market: 'Chittagong - Coconut Market',
        date: DateTime.now(),
        previousPrice: 25.00,
        description: 'Fresh coconuts',
        minPrice: 22.00,
        maxPrice: 32.00,
        avgPrice: 28.00,
      ),
    ];
  }
}

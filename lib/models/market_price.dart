/// Model for market price data
class MarketPrice {
  final String id;
  final String cropName;
  final String category;
  final double price;
  final String unit;
  final String market;
  final DateTime date;
  final String? imageUrl;
  final double? previousPrice;
  final List<PriceHistory>? priceHistory;
  final String? description;
  final double? minPrice;
  final double? maxPrice;
  final double? avgPrice;

  MarketPrice({
    required this.id,
    required this.cropName,
    required this.category,
    required this.price,
    required this.unit,
    required this.market,
    required this.date,
    this.imageUrl,
    this.previousPrice,
    this.priceHistory,
    this.description,
    this.minPrice,
    this.maxPrice,
    this.avgPrice,
  });

  double? get priceChangePercentage {
    if (previousPrice == null || previousPrice == 0) return null;
    return ((price - previousPrice!) / previousPrice!) * 100;
  }

  bool get isPriceIncreased {
    if (previousPrice == null) return false;
    return price > previousPrice!;
  }

  String get priceTrend {
    if (previousPrice == null) return 'Unknown';
    if (price > previousPrice!) return 'Increasing';
    if (price < previousPrice!) return 'Decreasing';
    return 'Stable';
  }

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      id: json['id'],
      cropName: json['cropName'],
      category: json['category'],
      price: json['price'].toDouble(),
      unit: json['unit'],
      market: json['market'],
      date: DateTime.parse(json['date']),
      imageUrl: json['imageUrl'],
      previousPrice: json['previousPrice']?.toDouble(),
      priceHistory: json['priceHistory'] != null
          ? (json['priceHistory'] as List)
              .map((e) => PriceHistory.fromJson(e))
              .toList()
          : null,
      description: json['description'],
      minPrice: json['minPrice']?.toDouble(),
      maxPrice: json['maxPrice']?.toDouble(),
      avgPrice: json['avgPrice']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropName': cropName,
      'category': category,
      'price': price,
      'unit': unit,
      'market': market,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'previousPrice': previousPrice,
      'priceHistory': priceHistory?.map((e) => e.toJson()).toList(),
      'description': description,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'avgPrice': avgPrice,
    };
  }
}

class PriceHistory {
  final DateTime date;
  final double price;

  PriceHistory({
    required this.date,
    required this.price,
  });

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
      date: DateTime.parse(json['date']),
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'price': price,
    };
  }
}

class PriceAlert {
  final String id;
  final String cropId;
  final String cropName;
  final double targetPrice;
  final String condition;
  final bool isActive;
  final DateTime createdAt;

  PriceAlert({
    required this.id,
    required this.cropId,
    required this.cropName,
    required this.targetPrice,
    required this.condition,
    required this.isActive,
    required this.createdAt,
  });

  factory PriceAlert.fromJson(Map<String, dynamic> json) {
    return PriceAlert(
      id: json['id'],
      cropId: json['cropId'],
      cropName: json['cropName'],
      targetPrice: json['targetPrice'].toDouble(),
      condition: json['condition'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropId': cropId,
      'cropName': cropName,
      'targetPrice': targetPrice,
      'condition': condition,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Weather data model for dashboard
class Weather {
  final double temperature;
  final String condition;
  final String location;
  final int humidity;
  final double windSpeed;
  final String icon;
  final DateTime lastUpdated;

  Weather({
    required this.temperature,
    required this.condition,
    required this.location,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    required this.lastUpdated,
  });

  /// Create Weather from JSON
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      condition: json['condition'] ?? 'Clear',
      location: json['location'] ?? 'Unknown',
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['windSpeed'] ?? 0.0).toDouble(),
      icon: json['icon'] ?? 'sunny',
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert Weather to JSON
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition,
      'location': location,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'icon': icon,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create mock weather data for demo
  static Weather mock() {
    return Weather(
      temperature: 28.5,
      condition: 'Partly Cloudy',
      location: 'Dhaka, Bangladesh',
      humidity: 65,
      windSpeed: 12.5,
      icon: 'partly_cloudy',
      lastUpdated: DateTime.now(),
    );
  }
}

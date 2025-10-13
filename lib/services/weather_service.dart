import '../models/weather_model.dart';

/// Service to handle weather data
class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  /// Get current weather data
  /// In a real app, this would fetch from a weather API
  Future<Weather> getCurrentWeather() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data for demo
    return Weather.mock();
  }

  /// Get weather forecast for next days
  Future<List<Weather>> getWeatherForecast({int days = 7}) async {
    await Future.delayed(const Duration(seconds: 1));

    // Generate mock forecast data
    final List<Weather> forecast = [];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      forecast.add(Weather(
        temperature: 25.0 + (i * 2) + (DateTime.now().millisecond % 10),
        condition: _getRandomCondition(),
        location: 'Dhaka, Bangladesh',
        humidity: 60 + (i * 5),
        windSpeed: 10.0 + (i * 1.5),
        icon: _getRandomIcon(),
        lastUpdated: now.add(Duration(days: i)),
      ));
    }

    return forecast;
  }

  /// Get random weather condition for mock data
  String _getRandomCondition() {
    final conditions = [
      'Sunny',
      'Partly Cloudy',
      'Cloudy',
      'Rainy',
      'Thunderstorm'
    ];
    return conditions[DateTime.now().millisecond % conditions.length];
  }

  /// Get random weather icon for mock data
  String _getRandomIcon() {
    final icons = ['sunny', 'partly_cloudy', 'cloudy', 'rainy', 'thunderstorm'];
    return icons[DateTime.now().millisecond % icons.length];
  }
}

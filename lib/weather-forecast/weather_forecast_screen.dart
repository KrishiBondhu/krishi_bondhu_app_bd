import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({Key? key}) : super(key: key);

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _weatherData;
  String _currentCity = "Dhaka"; // Default city

  @override
  void initState() {
    super.initState();
    // Fetch weather for the default location (Dhaka) when the screen loads
    _fetchWeatherForCity("Dhaka"); 
  }

  /// Fetches coordinates for a city name using the Open-Meteo Geocoding API
  Future<Map<String, double>> _getCoordinatesForCity(String city) async {
    try {
      final geoUrl = "https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(city)}&count=1";
      final response = await http.get(Uri.parse(geoUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0];
          return {
            'latitude': location['latitude'] as double,
            'longitude': location['longitude'] as double,
          };
        } else {
          throw Exception("City not found. Please try another city.");
        }
      } else {
        throw Exception("Failed to fetch location data.");
      }
    } catch (e) {
      // Re-throw the exception to be caught by the calling function
      throw Exception("Error finding city: ${e.toString()}");
    }
  }

  /// Fetches weather data from Open-Meteo using latitude and longitude
  Future<void> _fetchWeather(double latitude, double longitude) async {
    try {
      // API URL for current weather, 24-hour hourly forecast, and 7-day daily forecast
      final weatherUrl = 
          "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&hourly=temperature_2m,weathercode&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=auto";

      final response = await http.get(Uri.parse(weatherUrl));

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        throw Exception("Failed to load weather data.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// Main function to search for a city and fetch its weather
  Future<void> _fetchWeatherForCity(String city) async {
    if (city.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentCity = city; // Optimistically update the city name
    });

    try {
      // 1. Get coordinates for the city
      final coordinates = await _getCoordinatesForCity(city);
      final lat = coordinates['latitude'];
      final lon = coordinates['longitude'];

      if (lat != null && lon != null) {
        // 2. Fetch weather for those coordinates
        await _fetchWeather(lat, lon);
      } else {
        throw Exception("Could not find coordinates for $city.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Forecast"),
        backgroundColor: const Color(0xFF4CAF50), // Green color from your screenshot
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchCard(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildWeatherDisplay(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the search bar UI
  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search for a city...",
            border: InputBorder.none,
            icon: const Icon(Icons.search),
          ),
          onSubmitted: (value) {
            _fetchWeatherForCity(value);
          },
        ),
      ),
    );
  }

  /// Builds the main content area based on the state (loading, error, data)
  Widget _buildWeatherDisplay() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_weatherData == null) {
      return const Center(child: Text("No weather data available."));
    }

    // If we have data, build the full weather UI
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentWeather(),
          const SizedBox(height: 20),
          _buildHourlyForecast(),
          const SizedBox(height: 20),
          _buildDailyForecast(),
        ],
      ),
    );
  }

  /// Builds the "Current Weather" card
  Widget _buildCurrentWeather() {
    final currentWeather = _weatherData!['current_weather'];
    final daily = _weatherData!['daily'];
    
    final int weatherCode = currentWeather['weathercode'].round();
    final String temp = currentWeather['temperature'].round().toString();
    final String maxTemp = daily['temperature_2m_max'][0].round().toString();
    final String minTemp = daily['temperature_2m_min'][0].round().toString();


    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF4CAF50), // Green color
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentCity,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$temp°C",
                      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300, color: Colors.white),
                    ),
                    Text(
                      _getWeatherDescription(weatherCode),
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                  ],
                ),
                Icon(_getWeatherIcon(weatherCode), size: 80, color: Colors.white),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Day $maxTemp°C / Night $minTemp°C",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the "Hourly Forecast" horizontal list
  Widget _buildHourlyForecast() {
    final hourly = _weatherData!['hourly'];
    // We need to find the current hour to start the forecast from
    final now = DateTime.now();
    final int currentHour = int.parse(DateFormat('H').format(now));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Hourly Forecast",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 24, // Show next 24 hours
            itemBuilder: (context, index) {
              final int hourIndex = currentHour + index;
              if (hourIndex >= hourly['time'].length) {
                return const SizedBox.shrink(); // Avoid index out of bounds
              }

              final time = DateTime.parse(hourly['time'][hourIndex]);
              final temp = hourly['temperature_2m'][hourIndex].round().toString();
              final weatherCode = hourly['weathercode'][hourIndex].round();

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('ha').format(time), // "10 AM", "11 AM"
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Icon(_getWeatherIcon(weatherCode), size: 30, color: Colors.blueGrey),
                      Text(
                        "$temp°C",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the "7-Day Forecast" vertical list
  Widget _buildDailyForecast() {
    final daily = _weatherData!['daily'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "7-Day Forecast",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true, // Important for nested scrolling
          physics: const NeverScrollableScrollPhysics(), // Important for nested scrolling
          itemCount: 7,
          itemBuilder: (context, index) {
            final date = DateTime.parse(daily['time'][index]);
            final maxTemp = daily['temperature_2m_max'][index].round().toString();
            final minTemp = daily['temperature_2m_min'][index].round().toString();
            final weatherCode = daily['weathercode'][index].round();
            
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Icon(_getWeatherIcon(weatherCode), color: Colors.blueGrey, size: 30),
                title: Text(
                  DateFormat('EEEE, MMM d').format(date), // "Tuesday, Nov 4"
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_getWeatherDescription(weatherCode)),
                trailing: Text(
                  "$maxTemp° / $minTemp°",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Helper function to get an Icon based on the WMO weather code
  IconData _getWeatherIcon(int code) {
    switch (code) {
      case 0: return Icons.wb_sunny; // Clear sky
      case 1:
      case 2:
      case 3: return Icons.cloud; // Mainly clear, partly cloudy, overcast
      case 45:
      case 48: return Icons.foggy; // Fog
      case 51:
      case 53:
      case 55: return Icons.grain; // Drizzle
      case 61:
      case 63:
      case 65: return Icons.water_drop; // Rain
      case 66:
      case 67: return Icons.ac_unit; // Freezing Rain
      case 71:
      case 73:
      case 75: return Icons.snowing; // Snow
      case 80:
      case 81:
      case 82: return Icons.shower; // Rain showers
      case 95:
      case 96:
      case 99: return Icons.thunderstorm; // Thunderstorm
      default: return Icons.cloud_outlined;
    }
  }

  /// Helper function to get a description string from the weather code
  String _getWeatherDescription(int code) {
    switch (code) {
      case 0: return "Clear Sky";
      case 1: return "Mainly Clear";
      case 2: return "Partly Cloudy";
      case 3: return "Overcast";
      case 45:
      case 48: return "Fog";
      case 51: return "Light Drizzle";
      case 53: return "Drizzle";
      case 55: return "Heavy Drizzle";
      case 61: return "Slight Rain";
      case 63: return "Rain";
      case 65: return "Heavy Rain";
      case 80: return "Slight Showers";
      case 81: return "Rain Showers";
      case 82: return "Violent Showers";
      case 95: return "Thunderstorm";
      default: return "Cloudy";
    }
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherDetailScreen extends StatelessWidget {
  // It now receives a single processed item
  final Map<String, dynamic> dailyItem;

  const WeatherDetailScreen({
    super.key,
    required this.dailyItem,
  });

  @override
  Widget build(BuildContext context) {
    // Parse the data from the item
    final date = DateTime.fromMillisecondsSinceEpoch((dailyItem['dt'] ?? 0));
    final maxTemp = (dailyItem['temp_max'] ?? 0.0).round();
    final minTemp = (dailyItem['temp_min'] ?? 0.0).round();
    final rain = (dailyItem['rain'] ?? 0.0).toDouble();
    final wind = (dailyItem['wind'] ?? 0.0).toDouble();
    final sunrise = DateFormat('jm').format(DateTime.fromMillisecondsSinceEpoch(
        (dailyItem['sunrise'] ?? 0) * 1000));
    final sunset = DateFormat('jm').format(
        DateTime.fromMillisecondsSinceEpoch((dailyItem['sunset'] ?? 0) * 1000));
    final code = (dailyItem['code'] ?? 800).round();
    final description =
        dailyItem['description'] ?? _getWeatherDescriptionBangla(code);

    // Get the hourly list for this day
    final hourlyItems = (dailyItem['hourly_items'] as List);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(DateFormat('EEEE, d MMMM').format(date)),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(_getWeatherIcon(code),
                      size: 100, color: const Color(0xFF4CAF50)),
                  const SizedBox(height: 20),
                  Text(
                    description, // Use the real description
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32)),
                  ),
                  Text(
                    "$maxTemp° / $minTemp°",
                    style: TextStyle(fontSize: 22, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                _buildDetailCard("বৃষ্টিপাত (Rain)", "$rain mm",
                    Icons.water_drop, Colors.blue),
                _buildDetailCard(
                    "বাতাস (Wind)", "$wind km/h", Icons.air, Colors.teal),
                _buildDetailCard("সূর্যোদয় (Sunrise)", sunrise, Icons.wb_sunny,
                    Colors.orange),
                _buildDetailCard("সূর্যাস্ত (Sunset)", sunset,
                    Icons.nightlight_round, Colors.indigo),
              ],
            ),
            const SizedBox(height: 30),
            _buildSectionHeader("এই দিনের পূর্বাভাস", Icons.access_time),
            // Show the hourly items for this day
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: hourlyItems.length,
                itemBuilder: (context, index) {
                  final item = hourlyItems[index];
                  final time = DateTime.fromMillisecondsSinceEpoch(
                      (item['dt'] ?? 0) * 1000);
                  final temp = (item['main']['temp'] ?? 0.0).round();
                  final code = (item['weather'][0]['id'] ?? 800).round();
                  bool isRainy = code >= 300 && code < 700;

                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: (isRainy ? Colors.blue[50] : Colors.white),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: isRainy
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(DateFormat('ha').format(time),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        Icon(_getWeatherIcon(code),
                            size: 32,
                            color: isRainy ? Colors.blue : Colors.orange),
                        Text("$temp°",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 24),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20))),
        ],
      ),
    );
  }

  // --- Helper Functions for OWM Codes ---
  IconData _getWeatherIcon(int code) {
    if (code >= 200 && code < 300) {
      return Icons.thunderstorm_rounded; // Thunderstorm
    } else if (code >= 300 && code < 400) {
      return Icons.grain_rounded; // Drizzle
    } else if (code >= 500 && code < 600) {
      return Icons.water_drop_rounded; // Rain
    } else if (code >= 600 && code < 700) {
      return Icons.ac_unit_rounded; // Snow
    } else if (code >= 700 && code < 800) {
      return Icons.foggy; // Atmosphere (Fog, Mist)
    } else if (code == 800) {
      return Icons.wb_sunny_rounded; // Clear
    } else if (code == 801) {
      return Icons.wb_cloudy_rounded; // Few Clouds
    } else if (code > 801 && code < 900) {
      return Icons.cloud_rounded; // Clouds
    } else {
      return Icons.cloud_outlined;
    }
  }

  String _getWeatherDescriptionBangla(int code) {
    if (code >= 200 && code < 300) {
      return "বজ্রসহ বৃষ্টি";
    } else if (code >= 300 && code < 400) {
      return "গুঁড়ি গুঁড়ি বৃষ্টি";
    } else if (code >= 500 && code < 600) {
      return "বৃষ্টি";
    } else if (code >= 600 && code < 700) {
      return "তুষার";
    } else if (code >= 700 && code < 800) {
      return "কুয়াশা";
    } else if (code == 800) {
      return "রৌদ্রোজ্জ্বল";
    } else if (code == 801) {
      return "আংশিক মেঘলা";
    } else if (code > 801 && code < 900) {
      return "মেঘলা";
    } else {
      return "মেঘলা";
    }
  }
}

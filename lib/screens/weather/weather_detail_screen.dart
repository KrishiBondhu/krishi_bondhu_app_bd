import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather_icons.dart'; // <-- IMPORT THE SHARED ICONS
// import '../../utils/constants.dart';
// import 'weather_full_screen.dart';

class WeatherDetailScreen extends StatelessWidget {
  // This map is passed from the main screen
  final Map<String, dynamic> dailyItem;

  const WeatherDetailScreen({super.key, required this.dailyItem});

  @override
  Widget build(BuildContext context) {
    // Get the data from the map
    final date = DateTime.fromMillisecondsSinceEpoch(dailyItem['dt'] ?? 0);
    final min = (dailyItem['temp_min'] ?? 0.0).round();
    final max = (dailyItem['temp_max'] ?? 0.0).round();
    final code = (dailyItem['code'] ?? 800).round();
    final description = dailyItem['description'] ?? 'N/A';

    // Get the hourly list
    final List hourlyItems = dailyItem['hourly_items'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(DateFormat('EEEE, d MMM').format(date)),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Main Summary Card ---
            _buildMainSummaryCard(max, min, code, description),
            const SizedBox(height: 30),

            // --- 2. Agri Info Grid ---
            _buildSectionHeader("বিস্তারিত কৃষি তথ্য", Icons.info_outline),
            _buildDetailGrid(),
            const SizedBox(height: 30),

            // --- 3. Hourly Forecast List ---
            _buildSectionHeader("ঘণ্টা অনুযায়ী", Icons.access_time),
            _buildHourlyForecast(hourlyItems),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSummaryCard(int max, int min, int code, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Icon(getWeatherIcon(code),
              color: Colors.white, size: 100), // <-- USE SHARED ICON
          const SizedBox(height: 16),
          Text(description,
              style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("সর্বোচ্চ: $max° / সর্বনিম্ন: $min°",
              style: const TextStyle(fontSize: 20, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildDetailGrid() {
    final rain = (dailyItem['rain'] ?? 0.0).toStringAsFixed(1);
    final wind = (dailyItem['wind'] ?? 0.0).toStringAsFixed(1);
    final sunrise = DateFormat('jm').format(DateTime.fromMillisecondsSinceEpoch(
        (dailyItem['sunrise'] ?? 0) * 1000));
    final sunset = DateFormat('jm').format(
        DateTime.fromMillisecondsSinceEpoch((dailyItem['sunset'] ?? 0) * 1000));

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildAgriCard(
            "মোট বৃষ্টিপাত", "$rain মিমি", Icons.water_drop, Colors.blue),
        _buildAgriCard("বাতাসের গতি", "$wind কিমি/ঘ", Icons.air, Colors.teal),
        _buildAgriCard(
            "সূর্যোদয়", sunrise, Icons.wb_sunny_outlined, Colors.orange),
        _buildAgriCard(
            "সূর্যাস্ত", sunset, Icons.wb_twilight_rounded, Colors.deepOrange),
      ],
    );
  }

  Widget _buildAgriCard(
      String title, String value, IconData icon, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              radius: 20,
              child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(height: 8),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(List hourlyItems) {
    if (hourlyItems.isEmpty) {
      return const Center(child: Text("ঘণ্টার ডেটা নেই।"));
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: hourlyItems.length,
        itemBuilder: (context, index) {
          final item = hourlyItems[index];
          final time =
              DateTime.fromMillisecondsSinceEpoch((item['dt'] ?? 0) * 1000);
          final temp = (item['main']['temp'] ?? 0.0).round();
          final code = (item['weather'][0]['id'] ?? 800).round();

          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(DateFormat('ha').format(time),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87)),
                Icon(getWeatherIcon(code), // <-- USE SHARED ICON
                    size: 32,
                    color: code >= 300 && code < 700
                        ? Colors.blue
                        : Colors.orange),
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
}

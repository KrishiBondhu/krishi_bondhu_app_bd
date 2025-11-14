import 'package:flutter/material.dart'; // <-- This is the only import you need

/// Helper function to get the right icon based on the OpenWeatherMap code
IconData getWeatherIcon(int code) {
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

import 'package:flutter/material.dart';

/// Farm activity model for dashboard
class FarmActivity {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final DateTime timestamp;
  final String? cropName;
  final String? fieldName;

  FarmActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.cropName,
    this.fieldName,
  });

  /// Get icon for activity type
  IconData get icon {
    switch (type) {
      case ActivityType.planting:
        return Icons.agriculture;
      case ActivityType.watering:
        return Icons.water_drop;
      case ActivityType.harvesting:
        return Icons.grass;
      case ActivityType.fertilizing:
        return Icons.eco;
      case ActivityType.pestControl:
        return Icons.bug_report;
      case ActivityType.monitoring:
        return Icons.visibility;
    }
  }

  /// Get color for activity type
  Color get color {
    switch (type) {
      case ActivityType.planting:
        return Colors.green;
      case ActivityType.watering:
        return Colors.blue;
      case ActivityType.harvesting:
        return Colors.orange;
      case ActivityType.fertilizing:
        return Colors.brown;
      case ActivityType.pestControl:
        return Colors.red;
      case ActivityType.monitoring:
        return Colors.purple;
    }
  }

  /// Get formatted time string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Create mock activities for demo
  static List<FarmActivity> mockActivities() {
    return [
      FarmActivity(
        id: '1',
        title: 'Planted Rice Seeds',
        description: 'Planted rice seeds in Field A, Section 1',
        type: ActivityType.planting,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        cropName: 'Rice',
        fieldName: 'Field A',
      ),
      FarmActivity(
        id: '2',
        title: 'Watered Vegetables',
        description: 'Irrigation completed for vegetable section',
        type: ActivityType.watering,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        cropName: 'Vegetables',
        fieldName: 'Field B',
      ),
      FarmActivity(
        id: '3',
        title: 'Harvested Tomatoes',
        description: 'Collected 50kg of fresh tomatoes',
        type: ActivityType.harvesting,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        cropName: 'Tomatoes',
        fieldName: 'Field C',
      ),
      FarmActivity(
        id: '4',
        title: 'Applied Fertilizer',
        description: 'Organic fertilizer applied to wheat field',
        type: ActivityType.fertilizing,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        cropName: 'Wheat',
        fieldName: 'Field D',
      ),
    ];
  }
}

/// Types of farm activities
enum ActivityType {
  planting,
  watering,
  harvesting,
  fertilizing,
  pestControl,
  monitoring,
}

import 'package:flutter/material.dart';
const String kOpenWeatherApiKey = "4fa4e0c1e03c2e989b915bec887f48e1";
/// Application constants and color definitions
class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF388E3C);
  static const Color lightGreen = Color(0xFFC8E6C9);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFF8F9FA);
}

/// Text style constants
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: AppColors.grey,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.black,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.grey,
  );
}

/// App string constants
class AppStrings {
  static const String appName = 'KrishiBondhu';
  static const String tagline = 'Empowering Farmers, Growing Together';

  // Dashboard
  static const String welcomeMessage = 'Welcome back,';
  static const String dashboard = 'Dashboard';
  static const String quickActions = 'Quick Actions';
  static const String recentActivity = 'Recent Activity';
  static const String weatherToday = 'Today\'s Weather';

  // Quick Actions
  static const String cropManagement = 'Crop Management';
  static const String weatherForecast = 'Weather Forecast';
  static const String marketPrices = 'Market Prices';
  static const String expertAdvice = 'Expert Advice';
  static const String communityForum = 'Community Forum';
  static const String pestControl = 'Pest Control';

  // Navigation
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String logout = 'Logout';

  // Onboarding
  static const String onboarding1Title = 'Welcome to KrishiBondhu';
  static const String onboarding1Description =
      'Your digital companion for modern farming and agricultural solutions.';

  static const String onboarding2Title = 'Smart Farming Solutions';
  static const String onboarding2Description =
      'Get expert advice, weather updates, and crop management tools.';

  static const String onboarding3Title = 'Connect with Community';
  static const String onboarding3Description =
      'Join thousands of farmers sharing knowledge and experiences.';

  // Authentication
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
}

/// Dashboard action items
class QuickActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

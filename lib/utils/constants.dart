import 'package:flutter/material.dart';

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

  // ✅ Added missing colors
  static const Color textSecondary = Color(0xFF757575);
  static const Color red = Color(0xFFD32F2F);
  static const Color orange = Color(0xFFFF6F00);
  static const Color blue = Color(0xFF1976D2);
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
  static const String appName = 'কৃষি বন্ধু';
  static const String tagline = 'কৃষকদের ক্ষমতায়ন, একসাথে বৃদ্ধি';

  // Dashboard
  static const String welcomeMessage = 'স্বাগতম,';
  static const String dashboard = 'ড্যাশবোর্ড';
  static const String quickActions = 'দ্রুত কার্যক্রম';
  static const String recentActivity = 'সাম্প্রতিক কার্যক্রম';
  static const String weatherToday = 'আজকের আবহাওয়া';

  // Quick Actions
  static const String cropManagement = 'ফসল ব্যবস্থাপনা';
  static const String weatherForecast = 'আবহাওয়া পূর্বাভাস';
  static const String marketPrices = 'বাজার দর';
  static const String expertAdvice = 'বিশেষজ্ঞ পরামর্শ';
  static const String communityForum = 'কমিউনিটি ফোরাম';
  static const String pestControl = 'পোকামাকড় নিয়ন্ত্রণ';

  // Navigation
  static const String profile = 'প্রোফাইল';
  static const String settings = 'সেটিংস';
  static const String logout = 'লগআউট';

  // Onboarding
  static const String onboarding1Title = 'কৃষি বন্ধুতে স্বাগতম';
  static const String onboarding1Description =
      'আধুনিক কৃষি এবং কৃষি সমাধানের জন্য আপনার ডিজিটাল সঙ্গী।';

  static const String onboarding2Title = 'স্মার্ট কৃষি সমাধান';
  static const String onboarding2Description =
      'বিশেষজ্ঞ পরামর্শ, আবহাওয়া আপডেট এবং ফসল ব্যবস্থাপনা সরঞ্জাম পান।';

  static const String onboarding3Title = 'কমিউনিটির সাথে সংযুক্ত হন';
  static const String onboarding3Description =
      'হাজার হাজার কৃষক জ্ঞান এবং অভিজ্ঞতা ভাগ করে নিচ্ছেন, তাদের সাথে যোগ দিন।';

  // Authentication
  static const String login = 'লগইন';
  static const String signup = 'নিবন্ধন করুন';
  static const String email = 'ইমেইল';
  static const String password = 'পাসওয়ার্ড';
  static const String fullName = 'পুরো নাম';
  static const String phoneNumber = 'ফোন নম্বর';
  static const String forgotPassword = 'পাসওয়ার্ড ভুলে গেছেন?';
  static const String dontHaveAccount = "অ্যাকাউন্ট নেই?";
  static const String alreadyHaveAccount = 'ইতিমধ্যে অ্যাকাউন্ট আছে?';
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

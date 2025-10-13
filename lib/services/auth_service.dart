import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Authentication service to handle login and signup
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Login user with email and password
  Future<bool> login(String email, String password) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication logic
      if (email.isNotEmpty && password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setBool('is_logged_in', true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Register new user
  Future<bool> signup(String fullName, String email, String password,
      {String? phoneNumber}) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock registration logic
      if (fullName.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_name', fullName);
        if (phoneNumber != null) {
          await prefs.setString('user_phone', phoneNumber);
        }
        await prefs.setBool('is_logged_in', true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Get current user data
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final name = prefs.getString('user_name');

    if (email != null && name != null) {
      return User(
        id: '1',
        fullName: name,
        email: email,
        phoneNumber: prefs.getString('user_phone'),
        createdAt: DateTime.now(),
      );
    }
    return null;
  }
}

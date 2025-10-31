import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Authentication service with Firebase integration
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login user with email and password
  Future<bool> login(String email, String password) async {
    try {
      // Firebase Authentication login
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Save login state locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_id', credential.user!.uid);

        return true;
      }
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Login failed. Please try again.';
    }
  }

  /// Register new user
  Future<bool> signup(
    String fullName,
    String email,
    String password, {
    String? phoneNumber,
  }) async {
    try {
      // 1. Create Firebase Authentication user
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        final userId = credential.user!.uid;

        // 2. Save user data to Firestore Database
        // We also create the new fields as empty
        final newUser = User(
          id: userId,
          name: fullName.trim(),
          email: email.trim().toLowerCase(),
          phone: phoneNumber?.trim(),
          district: null,
          upazila: null,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(userId).set(newUser.toJson()
          ..addAll({'createdAt': FieldValue.serverTimestamp()}));

        // 3. Update Firebase Auth profile
        await credential.user!.updateDisplayName(fullName.trim());

        // 4. Send email verification (optional)
        await credential.user!.sendEmailVerification();

        // 5. Save login state locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_name', fullName);
        await prefs.setString('user_id', userId);
        if (phoneNumber != null) {
          await prefs.setString('user_phone', phoneNumber);
        }
        await prefs.setBool('is_logged_in', true);

        return true;
      }
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      print('FIRESTORE SIGNUP ERROR: ${e.toString()}');
      throw 'Failed to save user data. Please check console for details.';
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send reset email. Please try again.';
    }
  }

  /// Verify password reset code and reset password
  Future<bool> confirmPasswordReset(String code, String newPassword) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to reset password. Please try again.';
    }
  }

  /// Change password for logged in user
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw 'No user logged in';
      }

      // Re-authenticate user
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
      return true;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Re-throw your handled exception for the UI
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw 'Your current password is incorrect. Please try again.';
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to change password. Please try again.';
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    // Check both Firebase and local storage
    final firebaseUser = _firebaseAuth.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final localLogin = prefs.getBool('is_logged_in') ?? false;

    return firebaseUser != null && localLogin;
  }

  /// Logout user
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Get current user data from Firestore
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser != null) {
        // Get user data from Firestore
        final userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          // Use our User.fromJson factory
          return User.fromJson(data..addAll({'id': userDoc.id}));
        }
      }
      return null;
    } catch (e) {
      print("Error getting user: $e");
      return null;
    }
  }

  /// === NEW FUNCTION ===
  /// Update user profile data in Firestore
  Future<void> updateUserProfileData(
      String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update(data..addAll({'updatedAt': FieldValue.serverTimestamp()}));
    } catch (e) {
      print("Error updating user profile: $e");
      throw 'Failed to save profile. Please try again.';
    }
  }

  /// Get Firebase Auth user
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  /// Check if email is verified
  bool get isEmailVerified => _firebaseAuth.currentUser?.emailVerified ?? false;

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw 'Failed to send verification email.';
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'This email is already registered. Please login.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Operation not allowed.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Verification code has expired.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

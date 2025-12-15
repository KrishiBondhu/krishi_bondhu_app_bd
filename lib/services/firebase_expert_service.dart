import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Expert {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String specialization;
  final DateTime createdAt;

  Expert({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.specialization,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'specialization': specialization,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Expert.fromJson(Map<String, dynamic> json) => Expert(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String,
        specialization: json['specialization'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

class FirebaseExpertService extends ChangeNotifier {
  static final FirebaseExpertService instance = FirebaseExpertService._();
  FirebaseExpertService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Expert? _currentExpert;
  Expert? get currentExpert => _currentExpert;
  bool get isLoggedIn => _currentExpert != null;

  // Initialize and check if user is already logged in
  Future<void> initialize() async {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadExpertData(user.uid);
      } else {
        _currentExpert = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadExpertData(String uid) async {
    try {
      final doc = await _firestore.collection('experts').doc(uid).get();
      if (doc.exists) {
        _currentExpert = Expert.fromJson(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error loading expert data: $e');
    }
  }

  // Sign up new expert
  Future<String?> signUp({
    required String name,
    required String phone,
    required String password,
    required String specialization,
  }) async {
    try {
      // Create email from phone number (since Firebase requires email)
      final email = '$phone@krishibondhu.com';

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create expert document in Firestore
      final expert = Expert(
        id: userCredential.user!.uid,
        name: name,
        phone: phone,
        email: email,
        specialization: specialization,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('experts')
          .doc(userCredential.user!.uid)
          .set(expert.toJson());

      _currentExpert = expert;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'পাসওয়ার্ড খুবই দুর্বল';
      } else if (e.code == 'email-already-in-use') {
        return 'এই ফোন নম্বর দিয়ে ইতিমধ্যে একটি অ্যাকাউন্ট রয়েছে';
      }
      return 'সাইন আপ ব্যর্থ: ${e.message}';
    } catch (e) {
      return 'একটি ত্রুটি ঘটেছে: $e';
    }
  }

  // Login existing expert
  Future<String?> login({
    required String phone,
    required String password,
  }) async {
    try {
      final email = '$phone@krishibondhu.com';

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadExpertData(userCredential.user!.uid);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'এই ফোন নম্বর দিয়ে কোনো অ্যাকাউন্ট পাওয়া যায়নি';
      } else if (e.code == 'wrong-password') {
        return 'ভুল পাসওয়ার্ড';
      } else if (e.code == 'invalid-credential') {
        return 'ফোন নম্বর বা পাসওয়ার্ড ভুল';
      }
      return 'লগইন ব্যর্থ: ${e.message}';
    } catch (e) {
      return 'একটি ত্রুটি ঘটেছে: $e';
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentExpert = null;
    notifyListeners();
  }

  // For compatibility - keep the old method signature
  Future<void> ensureInitialized() async {
    await initialize();
  }
}

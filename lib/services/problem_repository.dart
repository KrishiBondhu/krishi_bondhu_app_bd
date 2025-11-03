import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProblemStatus { pending, answered }

class Problem {
  final String id;
  final String cropName;
  final String description;
  final String category;
  final bool urgent;
  final String? imagePath;
  final DateTime createdAt;
  final ProblemStatus status;
  final String? expertResponse;
  final DateTime? respondedAt;

  Problem({
    required this.id,
    required this.cropName,
    required this.description,
    required this.category,
    required this.urgent,
    required this.imagePath,
    required this.createdAt,
    this.status = ProblemStatus.pending,
    this.expertResponse,
    this.respondedAt,
  });

  Problem copyWith({
    String? id,
    String? cropName,
    String? description,
    String? category,
    bool? urgent,
    String? imagePath,
    DateTime? createdAt,
    ProblemStatus? status,
    String? expertResponse,
    DateTime? respondedAt,
  }) {
    return Problem(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      description: description ?? this.description,
      category: category ?? this.category,
      urgent: urgent ?? this.urgent,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      expertResponse: expertResponse ?? this.expertResponse,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropName': cropName,
        'description': description,
        'category': category,
        'urgent': urgent,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'expertResponse': expertResponse,
        'respondedAt': respondedAt?.toIso8601String(),
      };

  static Problem fromJson(Map<String, dynamic> j) => Problem(
        id: j['id'] as String,
        cropName: j['cropName'] as String,
        description: j['description'] as String,
        category: j['category'] as String,
        urgent: j['urgent'] as bool? ?? false,
        imagePath: j['imagePath'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String),
        status: (j['status'] == 'answered')
            ? ProblemStatus.answered
            : ProblemStatus.pending,
        expertResponse: j['expertResponse'] as String?,
        respondedAt: j['respondedAt'] != null
            ? DateTime.parse(j['respondedAt'] as String)
            : null,
      );
}

class ProblemRepository extends ChangeNotifier {
  ProblemRepository._();
  static final ProblemRepository instance = ProblemRepository._();

  static const _storageKey = 'kb_problems_v1';
  bool _loaded = false;
  List<Problem> _problems = [];

  Future<void> ensureInitialized() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => Problem.fromJson(e as Map<String, dynamic>))
          .toList();
      _problems = list;
    }
    _loaded = true;
    notifyListeners();
  }

  List<Problem> get problems => List.unmodifiable(_problems);
  List<Problem> get pending =>
      _problems.where((p) => p.status == ProblemStatus.pending).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  List<Problem> get answered => _problems
      .where((p) => p.status == ProblemStatus.answered)
      .toList()
    ..sort(
        (a, b) => b.respondedAt?.compareTo(a.respondedAt ?? DateTime(0)) ?? 0);

  Future<void> submit(Problem p) async {
    await ensureInitialized();
    _problems.add(p);
    await _save();
  }

  Future<void> markAnswered(
      {required String id, required String response}) async {
    await ensureInitialized();
    final idx = _problems.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final updated = _problems[idx].copyWith(
      status: ProblemStatus.answered,
      expertResponse: response,
      respondedAt: DateTime.now(),
    );
    _problems[idx] = updated;
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_problems.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
    notifyListeners();
  }
}

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_question.dart';

import 'package:firebase_auth/firebase_auth.dart';

class DailyQuestionService {
  DailyQuestionService._();

  static final DailyQuestionService instance = DailyQuestionService._();

  List<DailyQuestion>? _cachedQuestions;

  Future<List<DailyQuestion>> loadQuestions() async {
    if (_cachedQuestions != null) {
      return _cachedQuestions!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/data/daily_questions_v2.json',
    );

    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

    _cachedQuestions = jsonList
        .map((item) => DailyQuestion.fromJson(item as Map<String, dynamic>))
        .where((question) => question.isActive)
        .toList();

    return _cachedQuestions!;
  }

  Future<DailyQuestion?> getTodayQuestion({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final questions = await loadQuestions();

    try {
      return questions.firstWhere(
        (question) =>
            question.month == targetDate.month &&
            question.day == targetDate.day,
      );
    } catch (_) {
      return null;
    }
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _uidKey() {
    return FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  }

  String _answeredKey(DateTime date) {
    return 'daily_question_answered_${_uidKey()}_${_dateKey(date)}';
  }

  Future<bool> isTodayAnswered({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_answeredKey(targetDate)) ?? false;
  }

  Future<void> markTodayAnswered({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_answeredKey(targetDate), true);
  }

  String _dismissedKey(DateTime date) {
    return 'daily_question_dismissed_${_uidKey()}_${_dateKey(date)}';
  }

  Future<bool> isTodayDismissed({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_dismissedKey(targetDate)) ?? false;
  }

  Future<void> dismissToday({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_dismissedKey(targetDate), true);
  }
}

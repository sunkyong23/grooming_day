import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> isCurrentUserAdmin() async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) return false;

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return false;

      final data = doc.data();

      return data?['isAdmin'] == true;
    } catch (e) {
      return false;
    }
  }

  static DateTime get _todayStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static Future<int> countCollection(String collectionName) async {
    final snapshot = await _firestore.collection(collectionName).get();
    return snapshot.docs.length;
  }

  static Future<int> countTodayCollection(String collectionName) async {
    final snapshot = await _firestore
        .collection(collectionName)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(_todayStart),
        )
        .get();

    return snapshot.docs.length;
  }

  static Future<int> countReports() async {
    final snapshot = await _firestore
        .collection('reports')
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs.length;
  }

  static Future<int> countUserReports() async {
    final snapshot = await _firestore
        .collection('userReports')
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs.length;
  }

  static Future<int> countReviews() async {
    final snapshot = await _firestore.collectionGroup('reviews').get();
    return snapshot.docs.length;
  }

  static Future<int> countTodayReviews() async {
    final snapshot = await _firestore
        .collectionGroup('reviews')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(_todayStart),
        )
        .get();

    return snapshot.docs.length;
  }

  static Future<int> countRainbowLetters() async {
    final snapshot = await _firestore
        .collection('rainbowLetters')
        .where('isDeleted', isEqualTo: false)
        .get();

    return snapshot.docs.length;
  }

  static Future<int> countTodayRainbowLetters() async {
    final snapshot = await _firestore
        .collection('rainbowLetters')
        .where('isDeleted', isEqualTo: false)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(_todayStart),
        )
        .get();

    return snapshot.docs.length;
  }
}

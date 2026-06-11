import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserReportService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<void> reportUser({
    required String targetUid,
    required String targetUserId,
    required String reason,
    String detail = '',
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    if (targetUid == user.uid) {
      throw Exception('본인은 신고할 수 없어요.');
    }

    try {
      final existingReport = await _firestore
          .collection('userReports')
          .where('reporterUid', isEqualTo: user.uid)
          .where('targetUid', isEqualTo: targetUid)
          .limit(1)
          .get();

      if (existingReport.docs.isNotEmpty) {
        throw Exception('이미 신고한 사용자예요.');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final reporterUserId = userDoc.data()?['userId'] as String? ?? '';

      final docRef = _firestore.collection('userReports').doc();

      await docRef.set({
        'id': docRef.id,
        'reporterUid': user.uid,
        'reporterUserId': reporterUserId,
        'targetUid': targetUid,
        'targetUserId': targetUserId,
        'reason': reason,
        'detail': detail.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'processedAt': null,
        'processedBy': null,
      });
    } catch (e) {
      debugPrint('USER REPORT ERROR: $e');
      rethrow;
    }
  }

  static Stream<QuerySnapshot> reports() {
    return _firestore
        .collection('userReports')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

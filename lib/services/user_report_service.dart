import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserReportService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _currentUid => _auth.currentUser!.uid;

  static Future<void> reportUser({
    required String reporterUserId,
    required String targetUid,
    required String targetUserId,
    required String reason,
    String detail = '',
  }) async {
    final docRef = _firestore.collection('userReports').doc();

    await docRef.set({
      'id': docRef.id,
      'reporterUid': _currentUid,
      'reporterUserId': reporterUserId,
      'targetUid': targetUid,
      'targetUserId': targetUserId,
      'reason': reason,
      'detail': detail.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> reports() {
    return _firestore
        .collection('userReports')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

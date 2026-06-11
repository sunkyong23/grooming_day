import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  static Future<void> createReport({
    required String targetType,
    required String targetId,
    required String targetOwnerUid,
    required String reason,
    String? postId,
    String description = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final resolvedPostId = postId ?? (targetType == 'post' ? targetId : null);

    final existingReport = await FirebaseFirestore.instance
        .collection('reports')
        .where('reporterUid', isEqualTo: user.uid)
        .where('targetType', isEqualTo: targetType)
        .where('targetId', isEqualTo: targetId)
        .limit(1)
        .get();

    if (existingReport.docs.isNotEmpty) {
      throw Exception('이미 신고한 항목이에요.');
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final reporterUserId = userDoc.data()?['userId'] ?? '';

    final reportRef = FirebaseFirestore.instance.collection('reports').doc();

    await reportRef.set({
      'id': reportRef.id,
      'reporterUid': user.uid,
      'reporterUserId': reporterUserId,

      'targetType': targetType,
      'targetId': targetId,
      'postId': resolvedPostId,
      'targetOwnerUid': targetOwnerUid,

      'reason': reason,
      'description': description.trim(),

      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),

      'processedAt': null,
      'processedBy': null,
    });
  }
}

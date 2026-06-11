import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeService {
  static Stream<QuerySnapshot<Map<String, dynamic>>> notices() {
    return FirebaseFirestore.instance
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<Map<String, dynamic>?> loadNoticeById(String noticeId) async {
    if (noticeId.isEmpty) return null;

    final doc = await FirebaseFirestore.instance
        .collection('notices')
        .doc(noticeId)
        .get();

    if (!doc.exists) return null;

    return doc.data();
  }
}

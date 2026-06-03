import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeService {
  static Stream<QuerySnapshot<Map<String, dynamic>>> notices() {
    return FirebaseFirestore.instance
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

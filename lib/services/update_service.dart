import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateService {
  static Stream<QuerySnapshot<Map<String, dynamic>>> updates() {
    return FirebaseFirestore.instance
        .collection('updates')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<Map<String, dynamic>?> loadUpdateById(String updateId) async {
    if (updateId.isEmpty) return null;

    final doc = await FirebaseFirestore.instance
        .collection('updates')
        .doc(updateId)
        .get();

    if (!doc.exists) return null;

    return doc.data();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateService {
  static Stream<QuerySnapshot<Map<String, dynamic>>> updates() {
    return FirebaseFirestore.instance
        .collection('updates')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

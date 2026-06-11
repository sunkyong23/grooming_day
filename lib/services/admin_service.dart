import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static Future<bool> isCurrentUserAdmin() async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return false;

    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return false;

    final data = doc.data();

    return data?['isAdmin'] == true;
  }

  static Future<int> countCollection(String collectionName) async {
    final snapshot = await _firestore.collection(collectionName).get();
    return snapshot.docs.length;
  }

  static Future<int> countReports() async {
    final snapshot = await _firestore.collection('reports').limit(1).get();

    return snapshot.docs.length;
  }

  static Future<int> countUserReports() async {
    final snapshot = await _firestore
        .collection('userReports')
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs.length;
  }
}

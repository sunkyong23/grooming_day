import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BlockService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String get _currentUid => _auth.currentUser!.uid;

  static Future<void> blockUser({
    required String blockedUid,
    required String blockedUserId,
  }) async {
    await _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('blockedUsers')
        .doc(blockedUid)
        .set({
          'blockedUid': blockedUid,
          'blockedUserId': blockedUserId,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<void> unblockUser(String blockedUid) async {
    await _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('blockedUsers')
        .doc(blockedUid)
        .delete();
  }

  static Future<bool> isBlocked(String blockedUid) async {
    final doc = await _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('blockedUsers')
        .doc(blockedUid)
        .get();

    return doc.exists;
  }

  static Stream<QuerySnapshot> blockedUsers() {
    return _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('blockedUsers')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<List<String>> loadBlockedUserUids() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_currentUid)
        .collection('blockedUsers')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }
}

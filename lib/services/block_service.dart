import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BlockService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get _currentUid => _auth.currentUser?.uid;

  static Future<void> blockUser({
    required String blockedUid,
    required String blockedUserId,
  }) async {
    final currentUid = _currentUid;

    if (currentUid == null) {
      throw Exception('로그인이 필요합니다.');
    }

    if (currentUid == blockedUid) {
      throw Exception('자기 자신은 차단할 수 없어요.');
    }

    await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('blockedUsers')
        .doc(blockedUid)
        .set({
          'blockedUid': blockedUid,
          'blockedUserId': blockedUserId,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<void> unblockUser(String blockedUid) async {
    final currentUid = _currentUid;

    if (currentUid == null) {
      throw Exception('로그인이 필요합니다.');
    }

    await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('blockedUsers')
        .doc(blockedUid)
        .delete();
  }

  static Future<bool> isBlocked(String blockedUid) async {
    final currentUid = _currentUid;

    if (currentUid == null) return false;

    final doc = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('blockedUsers')
        .doc(blockedUid)
        .get();

    return doc.exists;
  }

  static Stream<QuerySnapshot> blockedUsers() {
    final currentUid = _currentUid;

    if (currentUid == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('blockedUsers')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<List<String>> loadBlockedUserUids() async {
    final currentUid = _currentUid;

    if (currentUid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('blockedUsers')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }
}

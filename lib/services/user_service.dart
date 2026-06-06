import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserService {
  static Future<Map<String, dynamic>?> loadCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    return doc.data();
  }

  static Future<String?> updateProfileImage(File file) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return null;

    final ref = FirebaseStorage.instance.ref('users/$uid/profile.jpg');

    await ref.putFile(file);

    final imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profileImageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return imageUrl;
  }

  static Future<void> updateBio(String bio) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'bio': bio,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteCurrentUserAccount() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final uid = user.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final userId = userDoc.data()?['userId'] ?? '';

    final postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('ownerUid', isEqualTo: uid)
        .get();

    for (final doc in postsSnapshot.docs) {
      final data = doc.data();
      final storagePath = data['storagePath'] ?? 'posts/$uid/${doc.id}.jpg';

      try {
        await FirebaseStorage.instance.ref(storagePath).delete();
      } catch (e) {
        // 이미지가 없거나 이미 삭제된 경우 무시
      }

      await FirebaseFirestore.instance.collection('posts').doc(doc.id).delete();
    }

    try {
      await FirebaseStorage.instance.ref('users/$uid/profile.jpg').delete();
    } catch (e) {
      // 프로필 이미지가 없거나 이미 삭제된 경우 무시
    }

    final scrapsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scraps')
        .get();

    for (final doc in scrapsSnapshot.docs) {
      await doc.reference.delete();
    }

    if (userId.toString().isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('userIds')
            .doc(userId)
            .delete();
      } catch (e) {
        // userIds 문서가 없거나 삭제 권한이 없을 경우 무시
      }
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).delete();

    await user.delete();
  }

  static Future<String> loadCurrentUserId() async {
    final data = await loadCurrentUser();

    if (data == null) return '';

    return data['userId'] ?? '';
  }

  static Future<bool> isUserIdDuplicated(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('userIds')
        .doc(userId)
        .get();

    return doc.exists;
  }

  static Future<bool> isUserIdAvailable(
    String userId,
    String currentUid,
  ) async {
    final doc = await FirebaseFirestore.instance
        .collection('userIds')
        .doc(userId)
        .get();

    if (!doc.exists) return true;

    final data = doc.data();

    return data?['uid'] == currentUid;
  }

  static Future<void> reserveUserId({
    required String uid,
    required String userId,
  }) async {
    await FirebaseFirestore.instance.collection('userIds').doc(userId).set({
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateProfile({
    required String uid,
    required String userId,
    required String bio,
  }) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    final currentUserDoc = await userRef.get();
    final currentUserId = currentUserDoc.data()?['userId'] ?? '';

    final batch = FirebaseFirestore.instance.batch();

    batch.update(userRef, {
      'userId': userId,
      'bio': bio,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (currentUserId != userId) {
      if (currentUserId.toString().isNotEmpty) {
        final oldUserIdRef = FirebaseFirestore.instance
            .collection('userIds')
            .doc(currentUserId);

        batch.delete(oldUserIdRef);
      }

      final newUserIdRef = FirebaseFirestore.instance
          .collection('userIds')
          .doc(userId);

      batch.set(newUserIdRef, {
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}

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

    final ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(uid)
        .child('profile.jpg');

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

    final postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('ownerUid', isEqualTo: uid)
        .get();

    for (final doc in postsSnapshot.docs) {
      final postId = doc.id;

      try {
        await FirebaseStorage.instance.ref('posts/$uid/$postId.jpg').delete();
      } catch (e) {
        // 이미지가 없거나 이미 삭제된 경우 무시
      }

      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
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

    await FirebaseFirestore.instance.collection('users').doc(uid).delete();

    await user.delete();
  }

  static Future<String> loadCurrentUserId() async {
    final data = await loadCurrentUser();

    if (data == null) return '';

    return data['userId'] ?? '';
  }
}

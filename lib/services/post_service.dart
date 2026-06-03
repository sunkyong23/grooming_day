import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/post.dart';

class PostService {
  static Future<List<Post>> loadPosts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Post(
        id: data['id'] ?? doc.id,
        imageUrl: data['imageUrl'] ?? '',
        caption: data['caption'] ?? '',
        likes: data['likes'] ?? 0,
        tags: List<String>.from(data['tags'] ?? []),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        aspectRatio: (data['aspectRatio'] ?? 4 / 5).toDouble(),
        catName: data['catName'] ?? '가을이',
        userId: data['userId'] ?? '',
        isAsset: false,
      );
    }).toList();
  }

  static Future<Set<String>> loadMyScrapIds() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return {};

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scraps')
        .get();

    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  static Future<void> setScrap({
    required Post post,
    required bool isScrapped,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final scrapRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scraps')
        .doc(post.id);

    if (isScrapped) {
      await scrapRef.set({
        'postId': post.id,
        'imageUrl': post.imageUrl,
        'caption': post.caption,
        'catName': post.catName,
        'userId': post.userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await scrapRef.delete();
    }
  }
}

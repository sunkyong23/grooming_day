import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/post.dart';

class PostService {
  static Future<Set<String>> _loadMyDeletedCatIds(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('catProfiles')
        .where('ownerUid', isEqualTo: uid)
        .where('isDeleted', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  static Post _postFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return Post(
      id: data['id'] ?? doc.id,
      ownerUid: data['ownerUid'] ?? '',
      userId: data['userId'] ?? '',
      catProfileId: data['catProfileId'] ?? '',
      catName: data['catName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      aspectRatio: (data['aspectRatio'] ?? 0.8).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] ?? false,
      isHidden: data['isHidden'] ?? false,
      reportCount: data['reportCount'] ?? 0,
      scrapCount: data['scrapCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      visibility: data['visibility'] ?? 'public',
    );
  }

  static Future<List<Post>> loadPosts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    final posts = snapshot.docs.map(_postFromDoc).toList();

    final visiblePosts = <Post>[];

    for (final post in posts) {
      if (post.tags.isEmpty) continue;
      if (post.catProfileId.isEmpty) continue;

      try {
        final catDoc = await FirebaseFirestore.instance
            .collection('catProfiles')
            .doc(post.catProfileId)
            .get();

        if (!catDoc.exists) continue;

        final catData = catDoc.data();

        if (catData == null) continue;
        if (catData['isDeleted'] == true) continue;
        if (catData['isHidden'] == true) continue;

        visiblePosts.add(post);
      } catch (_) {}
    }

    return visiblePosts;
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

  static Future<Post?> createPost({
    required File imageFile,
    required String caption,
    required List<String> tags,
    required double aspectRatio,
    required String catName,
    required String catProfileId,
    required String userId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final postId = FirebaseFirestore.instance.collection('posts').doc().id;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('posts')
        .child(user.uid)
        .child('$postId.jpg');

    await storageRef.putFile(imageFile);

    final imageUrl = await storageRef.getDownloadURL();

    final newPost = Post(
      id: postId,
      ownerUid: user.uid,
      userId: userId,
      catProfileId: catProfileId,
      catName: catName,
      imageUrl: imageUrl,
      caption: caption,
      tags: tags,
      aspectRatio: aspectRatio,
      createdAt: DateTime.now(),
      updatedAt: null,
      isDeleted: false,
      isHidden: false,
      reportCount: 0,
      scrapCount: 0,
      commentCount: 0,
      visibility: 'public',
    );

    await FirebaseFirestore.instance.collection('posts').doc(postId).set({
      'id': postId,
      'ownerUid': user.uid,
      'userId': userId,
      'catProfileId': catProfileId,
      'catName': catName,
      'imageUrl': imageUrl,
      'caption': caption,
      'tags': tags,
      'aspectRatio': aspectRatio,

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': null,

      'isDeleted': false,
      'isHidden': false,

      'reportCount': 0,
      'scrapCount': 0,
      'commentCount': 0,

      'visibility': 'public',
    });

    return newPost;
  }

  static Future<List<Post>> loadPostsByCatProfile(String catProfileId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('catProfileId', isEqualTo: catProfileId)
        .get();

    final posts = snapshot.docs.map(_postFromDoc).toList();

    posts.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return posts;
  }

  static Future<List<Post>> loadMyPosts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return [];

    final deletedCatIds = await _loadMyDeletedCatIds(uid);

    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('ownerUid', isEqualTo: uid)
        .get();

    final posts = snapshot.docs
        .map(_postFromDoc)
        .where((post) => !deletedCatIds.contains(post.catProfileId))
        .toList();

    posts.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return posts;
  }
}

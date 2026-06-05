import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

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
        catName: data['catName'] ?? '',
        catProfileId: data['catProfileId'] ?? '',
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
      imageUrl: imageUrl,
      caption: caption,
      likes: 0,
      tags: tags,
      createdAt: DateTime.now(),
      aspectRatio: aspectRatio,
      catName: catName,
      userId: userId,
      catProfileId: catProfileId,
      isAsset: false,
    );

    await FirebaseFirestore.instance.collection('posts').doc(postId).set({
      'id': postId,
      'imageUrl': imageUrl,
      'caption': caption,
      'likes': 0,
      'tags': tags,
      'createdAt': Timestamp.now(),
      'aspectRatio': aspectRatio,
      'catName': catName,
      'catProfileId': catProfileId,
      'userId': userId,
      'ownerUid': user.uid,
    });

    return newPost;
  }

  static Future<List<Post>> loadPostsByCatProfile(String catProfileId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('catProfileId', isEqualTo: catProfileId)
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
        aspectRatio: (data['aspectRatio'] ?? 0.8).toDouble(),
        catName: data['catName'] ?? '',
        catProfileId: data['catProfileId'] ?? '',
        userId: data['userId'] ?? '',
        isAsset: false,
      );
    }).toList();
  }
}

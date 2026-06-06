import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/post.dart';

class PostService {
  static Future<Set<String>> _loadDeletedCatIds() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('catProfiles')
        .where('isDeleted', isEqualTo: true)
        .get();

    return snapshot.docs
        .expand((doc) {
          final data = doc.data();

          return [doc.id, data['id'] ?? ''];
        })
        .where((id) => id.isNotEmpty)
        .cast<String>()
        .toSet();
  }

  static Future<Set<String>> _loadMyDeletedCatIds(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('catProfiles')
        .where('ownerUid', isEqualTo: uid)
        .where('isDeleted', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  static Future<Set<String>> _loadHiddenCatIds() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('catProfiles')
        .where('isHidden', isEqualTo: true)
        .get();

    return snapshot.docs
        .expand((doc) {
          final data = doc.data();

          return [doc.id, data['id'] ?? ''];
        })
        .where((id) => id.isNotEmpty)
        .cast<String>()
        .toSet();
  }

  static Post _postFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
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
  }

  static Future<List<Post>> loadPosts() async {
    final deletedCatIds = await _loadDeletedCatIds();
    final hiddenCatIds = await _loadHiddenCatIds();

    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(_postFromDoc)
        .where((post) => !deletedCatIds.contains(post.catProfileId))
        .where((post) => !hiddenCatIds.contains(post.catProfileId))
        .where((post) => post.tags.isNotEmpty)
        .toList();
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

    return snapshot.docs.map(_postFromDoc).toList();
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

    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return posts;
  }
}

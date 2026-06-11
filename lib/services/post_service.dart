import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/post.dart';
import '../services/image_service.dart';

class PostPage {
  final List<Post> posts;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  PostPage({
    required this.posts,
    required this.lastDocument,
    required this.hasMore,
  });
}

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
      catProfileImageUrl: data['catProfileImageUrl'] ?? '',
      isVirtualCat: data['isVirtualCat'] ?? false,
      imageUrl: data['imageUrl'] ?? '',
      storagePath: data['storagePath'] ?? '',
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
      unreadReviewCount: data['unreadReviewCount'] ?? 0,
    );
  }

  static Future<bool> _isVisibleCatProfile(String catProfileId) async {
    if (catProfileId.isEmpty) return false;

    try {
      final catDoc = await FirebaseFirestore.instance
          .collection('catProfiles')
          .doc(catProfileId)
          .get();

      if (!catDoc.exists) return false;

      final catData = catDoc.data();

      if (catData == null) return false;
      if (catData['isDeleted'] == true) return false;
      if (catData['isHidden'] == true) return false;

      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<PostPage> loadPostsPage({
    String? tag,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('posts')
        .where('isDeleted', isEqualTo: false)
        .where('isHidden', isEqualTo: false)
        .where('visibility', isEqualTo: 'public');

    if (tag != null && tag != '오늘의') {
      query = query.where('tags', arrayContains: tag);
    }

    if (tag == '오늘의') {
      query = query
          .orderBy('scrapCount', descending: true)
          .orderBy('createdAt', descending: true);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.limit(limit).get();

    final pagePosts = snapshot.docs.map(_postFromDoc).toList();
    final visiblePosts = <Post>[];

    for (final post in pagePosts) {
      if (post.tags.isEmpty) continue;

      if (await _isVisibleCatProfile(post.catProfileId)) {
        visiblePosts.add(post);
      }
    }

    return PostPage(
      posts: visiblePosts,
      lastDocument: snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : lastDocument,
      hasMore: snapshot.docs.length == limit,
    );
  }

  static Future<PostPage> loadMyPostsPage({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return PostPage(posts: [], lastDocument: null, hasMore: false);
    }

    final deletedCatIds = await _loadMyDeletedCatIds(uid);

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('posts')
        .where('ownerUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.limit(limit).get();

    final posts = snapshot.docs
        .map(_postFromDoc)
        .where((post) => !deletedCatIds.contains(post.catProfileId))
        .toList();

    return PostPage(
      posts: posts,
      lastDocument: snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : lastDocument,
      hasMore: snapshot.docs.length == limit,
    );
  }

  static Future<List<Post>> loadPosts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('isDeleted', isEqualTo: false)
        .where('isHidden', isEqualTo: false)
        .where('visibility', isEqualTo: 'public')
        .orderBy('createdAt', descending: true)
        .get();

    final posts = snapshot.docs.map(_postFromDoc).toList();

    final visiblePosts = <Post>[];

    for (final post in posts) {
      if (post.tags.isEmpty) continue;

      if (await _isVisibleCatProfile(post.catProfileId)) {
        visiblePosts.add(post);
      }
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

    final postRef = FirebaseFirestore.instance.collection('posts').doc(post.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final scrapSnapshot = await transaction.get(scrapRef);

      if (isScrapped) {
        if (scrapSnapshot.exists) return;

        transaction.set(scrapRef, {
          'postId': post.id,
          'ownerUid': post.ownerUid,
          'imageUrl': post.imageUrl,
          'caption': post.caption,
          'catName': post.catName,
          'userId': post.userId,
          'catProfileId': post.catProfileId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.update(postRef, {'scrapCount': FieldValue.increment(1)});
      } else {
        if (!scrapSnapshot.exists) return;

        transaction.delete(scrapRef);
        transaction.update(postRef, {'scrapCount': FieldValue.increment(-1)});
      }
    });
  }

  static Future<List<Post>> loadMyScrappedPosts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return [];

    final scrapSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scraps')
        .orderBy('createdAt', descending: true)
        .get();

    final posts = <Post>[];

    for (final scrapDoc in scrapSnapshot.docs) {
      final postId = scrapDoc.id;

      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (!postDoc.exists) continue;

      final data = postDoc.data();

      if (data == null) continue;
      if (data['isDeleted'] == true) continue;
      if (data['isHidden'] == true) continue;
      if (data['visibility'] != 'public') continue;

      posts.add(
        Post(
          id: data['id'] ?? postDoc.id,
          ownerUid: data['ownerUid'] ?? '',
          userId: data['userId'] ?? '',
          catProfileId: data['catProfileId'] ?? '',
          catName: data['catName'] ?? '',
          catProfileImageUrl: data['catProfileImageUrl'] ?? '',
          isVirtualCat: data['isVirtualCat'] ?? false,
          imageUrl: data['imageUrl'] ?? '',
          storagePath: data['storagePath'] ?? '',
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
          unreadReviewCount: data['unreadReviewCount'] ?? 0,
        ),
      );
    }

    return posts;
  }

  static Future<Post?> createPost({
    required File imageFile,
    required String caption,
    required List<String> tags,
    required double aspectRatio,
    required String catName,
    required String catProfileId,
    required String userId,
    required String catProfileImageUrl,
    required bool isVirtualCat,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final postId = FirebaseFirestore.instance.collection('posts').doc().id;
    final storagePath = 'posts/${user.uid}/$postId.jpg';
    final storageRef = FirebaseStorage.instance.ref().child(storagePath);

    await storageRef.putFile(imageFile);

    final imageUrl = await storageRef.getDownloadURL();

    final newPost = Post(
      id: postId,
      ownerUid: user.uid,
      userId: userId,
      catProfileId: catProfileId,
      catName: catName,
      catProfileImageUrl: catProfileImageUrl,
      isVirtualCat: isVirtualCat,
      imageUrl: imageUrl,
      storagePath: storagePath,
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
      visibility: tags.isEmpty ? 'private' : 'public',
      unreadReviewCount: 0,
    );

    await FirebaseFirestore.instance.collection('posts').doc(postId).set({
      'id': postId,
      'ownerUid': user.uid,
      'userId': userId,
      'catProfileId': catProfileId,
      'catName': catName,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'caption': caption,
      'tags': tags,
      'aspectRatio': aspectRatio,
      'catProfileImageUrl': catProfileImageUrl,
      'isVirtualCat': isVirtualCat,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': null,
      'isDeleted': false,
      'isHidden': false,
      'reportCount': 0,
      'scrapCount': 0,
      'commentCount': 0,
      'unreadReviewCount': 0,
      'visibility': tags.isEmpty ? 'private' : 'public',
    });

    return newPost;
  }

  static Future<List<Post>> loadPostsByCatProfile(
    String catProfileId, {
    bool includePrivate = false,
  }) async {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('posts')
        .where('catProfileId', isEqualTo: catProfileId)
        .where('isDeleted', isEqualTo: false)
        .where('isHidden', isEqualTo: false);

    if (!includePrivate) {
      query = query.where('visibility', isEqualTo: 'public');
    }

    final snapshot = await query.orderBy('createdAt', descending: true).get();

    return snapshot.docs.map(_postFromDoc).toList();
  }

  static Future<List<Post>> loadMyPosts() async {
    final page = await loadMyPostsPage(limit: 1000);
    return page.posts;
  }

  static Future<List<Post>> loadPostsByTag(String tag) async {
    final page = await loadPostsPage(tag: tag, limit: 50);
    return page.posts;
  }

  static Future<void> updatePost({
    required Post post,
    required String caption,
    required List<String> tags,
    required String catProfileId,
    required String catName,
    required String catProfileImageUrl,
    required bool isVirtualCat,
    File? newImageFile,
    double? newAspectRatio,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;
    if (post.ownerUid != uid) return;

    String imageUrl = post.imageUrl;
    String storagePath = post.storagePath;
    double aspectRatio = post.aspectRatio;

    if (newImageFile != null) {
      if (post.storagePath.isNotEmpty) {
        await FirebaseStorage.instance.ref().child(post.storagePath).delete();
      }

      storagePath = 'posts/$uid/${post.id}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);

      final compressedImage = await ImageService.compressImage(newImageFile);
      final uploadFile = compressedImage ?? newImageFile;

      await storageRef.putFile(uploadFile);
      imageUrl = await storageRef.getDownloadURL();
      aspectRatio = newAspectRatio ?? post.aspectRatio;
    }

    await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
      'caption': caption,
      'tags': tags,
      'catProfileId': catProfileId,
      'catName': catName,
      'catProfileImageUrl': catProfileImageUrl,
      'isVirtualCat': isVirtualCat,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'aspectRatio': aspectRatio,
      'visibility': tags.isEmpty ? 'private' : 'public',
      'updatedAt': FieldValue.serverTimestamp(),
      'isUpdated': true,
    });
  }

  static Future<void> deletePost(Post post) async {
    try {
      if (post.storagePath.isNotEmpty) {
        await FirebaseStorage.instance.ref().child(post.storagePath).delete();
      }

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(post.id)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createReview({
    required Post post,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;
    if (content.trim().isEmpty) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final reviewerUserId = userDoc.data()?['userId'] ?? '';

    final reviewRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .collection('reviews')
        .doc();

    await reviewRef.set({
      'id': reviewRef.id,
      'postId': post.id,
      'reviewerUid': user.uid,
      'reviewerUserId': reviewerUserId,
      'content': content.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'isDeleted': false,
    });

    final updateData = <String, dynamic>{
      'commentCount': FieldValue.increment(1),
    };

    if (post.ownerUid != user.uid) {
      updateData['unreadReviewCount'] = FieldValue.increment(1);
    }

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.id)
        .update(updateData);
  }

  static Future<void> clearUnreadReviewCount(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'unreadReviewCount': 0,
    });
  }

  static Future<Post?> loadPostById(String postId) async {
    final doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data();

    if (data == null) return null;
    if (data['isDeleted'] == true) return null;
    if (data['isHidden'] == true) return null;

    return Post.fromDoc(doc);
  }
}

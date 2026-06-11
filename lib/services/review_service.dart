import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/review.dart';
import 'user_service.dart';

class ReviewService {
  static Future<Review?> createReview({
    required String postId,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) return null;

    final writerUserId = await UserService.loadCurrentUserId();

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    final reviewRef = postRef.collection('reviews').doc();
    final reviewId = reviewRef.id;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      final postData = postSnapshot.data();

      if (postData == null) return;

      final ownerUid = postData['ownerUid'] ?? '';
      final postImageUrl = postData['imageUrl'] ?? '';

      transaction.set(reviewRef, {
        'id': reviewId,
        'postId': postId,
        'writerUid': user.uid,
        'writerUserId': writerUserId,
        'content': trimmedContent,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
        'isDeleted': false,
        'isHidden': false,
        'reportCount': 0,
      });

      final Map<String, Object> postUpdateData = {
        'commentCount': FieldValue.increment(1),
      };

      if (ownerUid != user.uid) {
        postUpdateData['unreadReviewCount'] = FieldValue.increment(1);

        final notificationRef = FirebaseFirestore.instance
            .collection('notifications')
            .doc();

        transaction.set(notificationRef, {
          'receiverUid': ownerUid,
          'senderUid': user.uid,
          'senderUserId': writerUserId,
          'type': 'review',
          'targetPostId': postId,
          'targetImageUrl': postImageUrl,
          'title': '새 감상평이 도착했어요',
          'body': '@$writerUserId 님이 내 게시글에 감상평을 남겼어요.',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      transaction.update(postRef, postUpdateData);
    });

    return Review(
      id: reviewId,
      postId: postId,
      writerUid: user.uid,
      writerUserId: writerUserId,
      content: trimmedContent,
      createdAt: DateTime.now(),
      updatedAt: null,
      isDeleted: false,
      isHidden: false,
      reportCount: 0,
    );
  }

  static Future<List<Review>> loadReviews(String postId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('reviews')
        .where('isDeleted', isEqualTo: false)
        .where('isHidden', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Review.fromDoc(doc)).toList();
  }

  Future<void> updateReview({
    required String postId,
    required String reviewId,
    required String content,
  }) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('reviews')
        .doc(reviewId)
        .update({
          'content': content,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> deleteReview({
    required String postId,
    required String reviewId,
  }) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final reviewRef = postRef.collection('reviews').doc(reviewId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);

      final currentCommentCount =
          (postSnapshot.data()?['commentCount'] ?? 0) as int;

      transaction.delete(reviewRef);

      transaction.update(postRef, {
        'commentCount': currentCommentCount > 0 ? currentCommentCount - 1 : 0,
      });
    });
  }
}

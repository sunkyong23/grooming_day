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

    final reviewRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('reviews')
        .doc();

    final reviewId = reviewRef.id;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
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

      transaction.update(postRef, {
        'commentCount': FieldValue.increment(1),
        'unreadReviewCount': FieldValue.increment(1),
      });
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

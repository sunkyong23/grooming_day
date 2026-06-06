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

    await reviewRef.set({
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

    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
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
}

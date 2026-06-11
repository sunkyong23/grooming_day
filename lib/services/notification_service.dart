import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createReviewNotification({
    required String receiverUid,
    required String senderUid,
    required String senderUserId,
    required String postId,
    required String postImageUrl,
  }) async {
    if (receiverUid.isEmpty || senderUid.isEmpty) return;
    if (receiverUid == senderUid) return;

    await _firestore.collection('notifications').add({
      'receiverUid': receiverUid,
      'senderUid': senderUid,
      'senderUserId': senderUserId,
      'type': 'review',
      'targetPostId': postId,
      'targetNoticeId': '',
      'targetUpdateId': '',
      'targetImageUrl': postImageUrl,
      'title': '새 감상평이 도착했어요',
      'body': '@$senderUserId 님이 내 게시글에 감상평을 남겼어요.',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createFavoriteCatPostNotifications({
    required String catProfileId,
    required String postOwnerUid,
    required String postOwnerUserId,
    required String catName,
    required String postId,
    required String postImageUrl,
  }) async {
    if (catProfileId.isEmpty) return;
    if (postOwnerUid.isEmpty) return;

    final snapshot = await _firestore
        .collectionGroup('favoriteCats')
        .where('catProfileId', isEqualTo: catProfileId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      final userDocRef = doc.reference.parent.parent;
      if (userDocRef == null) continue;

      final receiverUid = userDocRef.id;

      if (receiverUid.isEmpty) continue;
      if (receiverUid == postOwnerUid) continue;

      final notificationRef = _firestore.collection('notifications').doc();

      batch.set(notificationRef, {
        'receiverUid': receiverUid,
        'senderUid': postOwnerUid,
        'senderUserId': postOwnerUserId,
        'type': 'favorite_cat_post',
        'targetPostId': postId,
        'targetNoticeId': '',
        'targetUpdateId': '',
        'targetImageUrl': postImageUrl,
        'title': '$catName의 새 글이 올라왔어요',
        'body': '@$postOwnerUserId 님이 $catName의 새 게시글을 올렸어요.',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> createNoticeNotifications({
    required String noticeId,
    required String noticeTitle,
  }) async {
    if (noticeId.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final usersSnapshot = await _firestore.collection('users').get();

    if (usersSnapshot.docs.isEmpty) return;

    final batch = _firestore.batch();

    for (final userDoc in usersSnapshot.docs) {
      final receiverUid = userDoc.id;

      if (receiverUid.isEmpty) continue;
      if (receiverUid == currentUser.uid) continue;
      final notificationRef = _firestore.collection('notifications').doc();

      batch.set(notificationRef, {
        'receiverUid': receiverUid,
        'senderUid': currentUser.uid,
        'senderUserId': '그루밍데이',
        'type': 'notice',
        'targetPostId': '',
        'targetNoticeId': noticeId,
        'targetUpdateId': '',
        'targetImageUrl': '',
        'title': '새 공지가 올라왔어요',
        'body': noticeTitle,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Stream<List<AppNotification>> watchMyNotifications(String uid) {
    if (uid.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('notifications')
        .where('receiverUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppNotification.fromDoc(doc))
              .toList();
        });
  }

  Stream<bool> hasUnreadNotification(String uid) {
    if (uid.isEmpty) {
      return Stream.value(false);
    }

    return _firestore
        .collection('notifications')
        .where('receiverUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  Future<void> markAllAsRead(String uid) async {
    if (uid.isEmpty) return;

    final snapshot = await _firestore
        .collection('notifications')
        .where('receiverUid', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }
}

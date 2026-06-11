import 'package:cloud_firestore/cloud_firestore.dart';
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
      'targetImageUrl': postImageUrl,
      'title': '새 감상평이 도착했어요',
      'body': '@$senderUserId 님이 내 게시글에 감상평을 남겼어요.',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
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

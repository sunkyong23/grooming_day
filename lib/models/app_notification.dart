import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String receiverUid;
  final String senderUid;
  final String senderUserId;
  final String type;
  final String targetPostId;
  final String targetNoticeId;
  final String targetUpdateId;
  final String targetImageUrl;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.receiverUid,
    required this.senderUid,
    required this.senderUserId,
    required this.type,
    required this.targetPostId,
    required this.targetNoticeId,
    required this.targetUpdateId,
    required this.targetImageUrl,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final createdAtValue = data['createdAt'];

    return AppNotification(
      id: doc.id,
      receiverUid: data['receiverUid'] ?? '',
      senderUid: data['senderUid'] ?? '',
      senderUserId: data['senderUserId'] ?? '',
      type: data['type'] ?? '',
      targetPostId: data['targetPostId'] ?? '',
      targetNoticeId: data['targetNoticeId'] ?? '',
      targetUpdateId: data['targetUpdateId'] ?? '',
      targetImageUrl: data['targetImageUrl'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
    );
  }
}

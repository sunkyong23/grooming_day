import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String postId;
  final String writerUid;
  final String writerUserId;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final bool isHidden;
  final int reportCount;

  Review({
    required this.id,
    required this.postId,
    required this.writerUid,
    required this.writerUserId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
    this.isHidden = false,
    this.reportCount = 0,
  });

  factory Review.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Review(
      id: data['id'] ?? doc.id,
      postId: data['postId'] ?? '',
      writerUid: data['writerUid'] ?? '',
      writerUserId: data['writerUserId'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isDeleted: data['isDeleted'] ?? false,
      isHidden: data['isHidden'] ?? false,
      reportCount: data['reportCount'] ?? 0,
    );
  }
}

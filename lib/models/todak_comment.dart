import 'package:cloud_firestore/cloud_firestore.dart';

class TodakComment {
  final String id;
  final String letterId;
  final String writerUid;
  final String writerUserId;
  final String content;
  final bool isDeleted;
  final DateTime createdAt;

  TodakComment({
    required this.id,
    required this.letterId,
    required this.writerUid,
    required this.writerUserId,
    required this.content,
    required this.isDeleted,
    required this.createdAt,
  });

  factory TodakComment.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TodakComment(
      id: doc.id,
      letterId: data['letterId'] ?? '',
      writerUid: data['writerUid'] ?? '',
      writerUserId: data['writerUserId'] ?? '',
      content: data['content'] ?? '',
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class RainbowLetter {
  final String id;
  final String ownerUid;
  final String ownerUserId;
  final String title;
  final String catName;
  final String content;
  final String? imageUrl;
  final String? imageStoragePath;
  final int todakCount;
  final bool isPublic;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  RainbowLetter({
    required this.id,
    required this.ownerUid,
    required this.ownerUserId,
    required this.title,
    required this.catName,
    required this.content,
    this.imageUrl,
    this.imageStoragePath,
    this.todakCount = 0,
    this.isPublic = true,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RainbowLetter.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return RainbowLetter(
      id: doc.id,
      ownerUid: data['ownerUid'] ?? '',
      ownerUserId: data['ownerUserId'] ?? '',
      title: data['title'] ?? '',
      catName: data['catName'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      imageStoragePath: data['imageStoragePath'],
      todakCount: data['todakCount'] ?? 0,
      isPublic: data['isPublic'] ?? true,
      isDeleted: data['isDeleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerUid': ownerUid,
      'ownerUserId': ownerUserId,
      'title': title,
      'catName': catName,
      'content': content,
      'imageUrl': imageUrl,
      'imageStoragePath': imageStoragePath,
      'todakCount': todakCount,
      'isPublic': isPublic,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

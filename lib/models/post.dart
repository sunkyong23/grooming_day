import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String ownerUid;
  final String userId;
  final String catProfileId;
  final String catName;
  final String imageUrl;
  final String caption;
  final List<String> tags;
  final double aspectRatio;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  final bool isHidden;
  final int reportCount;
  final int scrapCount;
  final int commentCount;
  final String visibility;
  final String storagePath;
  final String catProfileImageUrl;
  final bool isVirtualCat;
  final int unreadReviewCount;

  Post({
    required this.id,
    required this.ownerUid,
    required this.userId,
    required this.catProfileId,
    required this.catName,
    required this.imageUrl,
    required this.caption,
    required this.tags,
    required this.aspectRatio,
    required this.createdAt,
    required this.catProfileImageUrl,
    required this.isVirtualCat,
    this.updatedAt,
    this.isDeleted = false,
    this.isHidden = false,
    this.reportCount = 0,
    this.scrapCount = 0,
    this.commentCount = 0,
    this.storagePath = '',
    this.unreadReviewCount = 0,

    this.visibility = 'public',
  });

  factory Post.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

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
      aspectRatio: (data['aspectRatio'] ?? 1.0).toDouble(),
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
}

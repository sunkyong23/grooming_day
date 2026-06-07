import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteCat {
  final String catProfileId;
  final String ownerUid;
  final String catName;
  final String catProfileImageUrl;
  final DateTime? createdAt;
  final String ownerUserId;

  FavoriteCat({
    required this.catProfileId,
    required this.ownerUid,
    required this.catName,
    required this.catProfileImageUrl,
    required this.createdAt,
    required this.ownerUserId,
  });

  factory FavoriteCat.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return FavoriteCat(
      catProfileId: data['catProfileId'] ?? doc.id,
      ownerUid: data['ownerUid'] ?? '',
      catName: data['catName'] ?? '',
      catProfileImageUrl: data['catProfileImageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      ownerUserId: data['ownerUserId'] ?? '',
    );
  }
}

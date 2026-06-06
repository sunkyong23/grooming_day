import 'package:cloud_firestore/cloud_firestore.dart';

class CatProfile {
  final String id;
  final String ownerUid;
  final String name;
  final String breed;
  final String gender;
  final DateTime? birthDate;
  final DateTime? adoptionDate;
  final String profileImageUrl;
  final String introduction;
  final List<String> personalityTags;
  final bool isRepresentative;
  final bool isPublic;

  final bool isHidden;
  final bool isDeleted;
  final bool isVirtualCat;
  final int sortOrder;

  final DateTime? createdAt;

  CatProfile({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.breed,
    required this.gender,
    this.birthDate,
    this.adoptionDate,
    required this.profileImageUrl,
    required this.introduction,
    required this.personalityTags,
    required this.isRepresentative,
    required this.isPublic,

    required this.isHidden,
    required this.isDeleted,
    required this.isVirtualCat,
    required this.sortOrder,

    this.createdAt,
  });

  factory CatProfile.fromMap(Map<String, dynamic> data) {
    return CatProfile(
      id: data['id'] ?? '',
      ownerUid: data['ownerUid'] ?? '',
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      gender: data['gender'] ?? 'unknown',
      birthDate: data['birthDate'] == null
          ? null
          : (data['birthDate'] as Timestamp).toDate(),
      adoptionDate: data['adoptionDate'] == null
          ? null
          : (data['adoptionDate'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'] ?? '',
      introduction: data['introduction'] ?? '',
      personalityTags: List<String>.from(data['personalityTags'] ?? []),
      isRepresentative: data['isRepresentative'] ?? false,
      isPublic: data['isPublic'] ?? true,
      isHidden: data['isHidden'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      isVirtualCat: data['isVirtualCat'] ?? false,
      sortOrder: data['sortOrder'] ?? 0,
      createdAt: data['createdAt'] == null
          ? null
          : (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerUid': ownerUid,
      'name': name,
      'breed': breed,
      'gender': gender,
      'birthDate': birthDate,
      'adoptionDate': adoptionDate,
      'profileImageUrl': profileImageUrl,
      'introduction': introduction,
      'personalityTags': personalityTags,
      'isRepresentative': isRepresentative,
      'isPublic': isPublic,
      'isHidden': isHidden,
      'isDeleted': isDeleted,
      'isVirtualCat': isVirtualCat,
      'sortOrder': sortOrder,
      'isVirtualCat': isVirtualCat,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

enum CatGender { male, female, unknown }

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
  final bool isRepresentative;

  final bool isHidden;
  final bool isDeleted;
  final int sortOrder;

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
    required this.isRepresentative,

    required this.isHidden,
    required this.isDeleted,
    required this.sortOrder,
  });

  factory CatProfile.fromMap(Map<String, dynamic> data) {
    return CatProfile(
      id: data['id'] ?? '',
      ownerUid: data['ownerUid'] ?? '',
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      gender: data['gender'] ?? '',
      birthDate: data['birthDate'] == null
          ? null
          : (data['birthDate'] as Timestamp).toDate(),
      adoptionDate: data['adoptionDate'] == null
          ? null
          : (data['adoptionDate'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'] ?? '',
      introduction: data['introduction'] ?? '',
      isRepresentative: data['isRepresentative'] ?? false,
      isHidden: data['isHidden'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      sortOrder: data['sortOrder'] ?? 0,
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
      'isRepresentative': isRepresentative,
      'isHidden': isHidden,
      'isDeleted': isDeleted,
      'sortOrder': sortOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

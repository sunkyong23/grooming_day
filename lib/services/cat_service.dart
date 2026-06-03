import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'user_service.dart';
import 'image_service.dart';

class CatService {
  static Future<void> createCat({
    required String name,
    required String breed,
    required String gender,
    File? imageFile,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final ownerUserId = await UserService.loadCurrentUserId();

    final catId = FirebaseFirestore.instance.collection('cats').doc().id;

    String profileImageUrl = '';

    if (imageFile != null) {
      profileImageUrl = await uploadCatProfileImage(
        imageFile: imageFile,
        ownerUid: uid,
        catProfileId: catId,
      );
    }

    await FirebaseFirestore.instance.collection('catProfiles').doc(catId).set({
      'id': catId,
      'ownerUid': uid,
      'ownerUserId': ownerUserId,

      'name': name,
      'breed': breed,
      'gender': gender,

      'profileImageUrl': profileImageUrl,
      'introduction': '',

      'isRepresentative': false,

      'isHidden': false,
      'isDeleted': false,
      'sortOrder': 0,

      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<String> uploadCatProfileImage({
    required File imageFile,
    required String ownerUid,
    required String catProfileId,
  }) async {
    final compressedImage = await ImageService.compressImage(imageFile);

    final uploadFile = compressedImage ?? imageFile;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('catProfiles')
        .child(ownerUid)
        .child(catProfileId)
        .child('profile.jpg');

    await storageRef.putFile(uploadFile);

    return storageRef.getDownloadURL();
  }
}

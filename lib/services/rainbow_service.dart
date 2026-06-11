import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'image_service.dart';

class RainbowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot> loadPublicLetters() {
    return _firestore
        .collection('rainbowLetters')
        .where('isDeleted', isEqualTo: false)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<QuerySnapshot> loadMyLetters() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return _firestore
        .collection('rainbowLetters')
        .where('ownerUid', isEqualTo: uid)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<QuerySnapshot> loadTodakComments(String letterId) {
    return _firestore
        .collection('rainbowLetters')
        .doc(letterId)
        .collection('todakComments')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt')
        .get();
  }

  Future<void> addTodakComment({
    required String letterId,
    required String writerUserId,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final commentRef = _firestore
        .collection('rainbowLetters')
        .doc(letterId)
        .collection('todakComments')
        .doc();

    await commentRef.set({
      'id': commentRef.id,
      'letterId': letterId,
      'writerUid': user.uid,
      'writerUserId': writerUserId,
      'content': content,
      'isDeleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': null,
    });

    await _firestore.collection('rainbowLetters').doc(letterId).update({
      'todakCount': FieldValue.increment(1),
    });
  }

  Future<void> updateTodakComment({
    required String letterId,
    required String commentId,
    required String content,
  }) async {
    await _firestore
        .collection('rainbowLetters')
        .doc(letterId)
        .collection('todakComments')
        .doc(commentId)
        .update({
          'content': content,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> deleteTodakComment({
    required String letterId,
    required String commentId,
  }) async {
    await _firestore
        .collection('rainbowLetters')
        .doc(letterId)
        .collection('todakComments')
        .doc(commentId)
        .update({'isDeleted': true, 'updatedAt': FieldValue.serverTimestamp()});

    await _firestore.collection('rainbowLetters').doc(letterId).update({
      'todakCount': FieldValue.increment(-1),
    });
  }

  Future<void> createLetter({
    required String title,
    required String catName,
    required String content,
    File? imageFile,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final ownerUserId = userDoc.data()?['userId'] ?? '';

    final docRef = _firestore.collection('rainbowLetters').doc();

    String? imageUrl;
    String? imageStoragePath;

    if (imageFile != null) {
      final compressedImage = await ImageService.compressImage(imageFile);
      final uploadFile = compressedImage ?? imageFile;

      imageStoragePath = 'rainbowLetters/${user.uid}/${docRef.id}.jpg';

      final storageRef = FirebaseStorage.instance.ref().child(imageStoragePath);

      await storageRef.putFile(uploadFile);

      imageUrl = await storageRef.getDownloadURL();
    }

    await docRef.set({
      'id': docRef.id,
      'ownerUid': user.uid,
      'ownerUserId': ownerUserId,
      'title': title,
      'catName': catName,
      'content': content,
      'imageUrl': imageUrl,
      'imageStoragePath': imageStoragePath,
      'todakCount': 0,
      'isPublic': true,
      'isDeleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLetter({
    required String letterId,
    required String title,
    required String catName,
    required String content,
  }) async {
    await _firestore.collection('rainbowLetters').doc(letterId).update({
      'title': title,
      'catName': catName,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, String?>> updateLetterImage({
    required String letterId,
    required String ownerUid,
    String? oldImageStoragePath,
    required File imageFile,
  }) async {
    if (oldImageStoragePath != null && oldImageStoragePath.isNotEmpty) {
      try {
        await FirebaseStorage.instance
            .ref()
            .child(oldImageStoragePath)
            .delete();
      } catch (e) {
        // 기존 이미지가 없거나 이미 삭제된 경우에도 새 이미지 업로드는 계속 진행
      }
    }

    final compressedImage = await ImageService.compressImage(imageFile);
    final uploadFile = compressedImage ?? imageFile;

    final newImageStoragePath = 'rainbowLetters/$ownerUid/$letterId.jpg';

    final storageRef = FirebaseStorage.instance.ref().child(
      newImageStoragePath,
    );

    await storageRef.putFile(uploadFile);

    final imageUrl = await storageRef.getDownloadURL();

    await _firestore.collection('rainbowLetters').doc(letterId).update({
      'imageUrl': imageUrl,
      'imageStoragePath': newImageStoragePath,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return {'imageUrl': imageUrl, 'imageStoragePath': newImageStoragePath};
  }

  Future<void> deleteLetter(String letterId) async {
    final doc = await _firestore
        .collection('rainbowLetters')
        .doc(letterId)
        .get();

    final data = doc.data();

    final imageStoragePath = data?['imageStoragePath'];

    if (imageStoragePath is String && imageStoragePath.isNotEmpty) {
      await FirebaseStorage.instance.ref().child(imageStoragePath).delete();
    }

    await _firestore.collection('rainbowLetters').doc(letterId).update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

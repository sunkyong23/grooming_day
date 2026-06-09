import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    });

    await _firestore.collection('rainbowLetters').doc(letterId).update({
      'todakCount': FieldValue.increment(1),
    });
  }

  Future<void> createLetter({
    required String title,
    required String catName,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final ownerUserId = userDoc.data()?['userId'] ?? '';

    final docRef = _firestore.collection('rainbowLetters').doc();

    await docRef.set({
      'id': docRef.id,
      'ownerUid': user.uid,
      'ownerUserId': ownerUserId,
      'title': title,
      'catName': catName,
      'content': content,
      'imageUrl': null,
      'imageStoragePath': null,
      'todakCount': 0,
      'isPublic': true,
      'isDeleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteLetter(String letterId) async {
    await _firestore.collection('rainbowLetters').doc(letterId).update({
      'isDeleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

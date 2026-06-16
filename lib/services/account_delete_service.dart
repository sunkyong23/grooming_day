import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AccountDeleteService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const int _batchLimit = 450;

  static Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }

    final uid = user.uid;

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    debugPrint('탈퇴 0: 재인증 시작');
    await user.reauthenticateWithCredential(credential);

    debugPrint('탈퇴 0-1: 재인증 성공');

    await _deleteUserData(uid);

    debugPrint('탈퇴 10: Auth 계정 삭제 시작');
    await user.delete();

    debugPrint('탈퇴 11: Auth 계정 삭제 완료');
  }

  static Future<void> _deleteUserData(String uid) async {
    final now = Timestamp.now();
    final operations = <void Function(WriteBatch batch)>[];

    debugPrint('탈퇴 1: users 업데이트 준비');
    operations.add((batch) {
      batch.update(_db.collection('users').doc(uid), {
        'isDeleted': true,
        'deletedAt': now,
        'updatedAt': now,
      });
    });

    debugPrint('탈퇴 2: catProfiles 조회 시작');
    final cats = await _db
        .collection('catProfiles')
        .where('ownerUid', isEqualTo: uid)
        .get();

    debugPrint('탈퇴 2-1: catProfiles ${cats.docs.length}개');

    for (final doc in cats.docs) {
      operations.add((batch) {
        batch.update(doc.reference, {
          'isDeleted': true,
          'deletedAt': now,
          'updatedAt': now,
        });
      });
    }

    debugPrint('탈퇴 3: posts 조회 시작');
    final posts = await _db
        .collection('posts')
        .where('ownerUid', isEqualTo: uid)
        .get();

    debugPrint('탈퇴 3-1: posts ${posts.docs.length}개');

    for (final postDoc in posts.docs) {
      operations.add((batch) {
        batch.update(postDoc.reference, {
          'isDeleted': true,
          'deletedAt': now,
          'updatedAt': now,
        });
      });

      debugPrint('탈퇴 3-2: post reviews 조회 시작 ${postDoc.id}');
      final reviews = await postDoc.reference.collection('reviews').get();

      debugPrint('탈퇴 3-3: post reviews ${reviews.docs.length}개');

      for (final reviewDoc in reviews.docs) {
        operations.add((batch) {
          batch.update(reviewDoc.reference, {
            'isDeleted': true,
            'deletedAt': now,
            'updatedAt': now,
          });
        });
      }
    }

    debugPrint('탈퇴 4: myReviews collectionGroup 조회 시작');
    final myReviews = await _db
        .collectionGroup('reviews')
        .where('writerUid', isEqualTo: uid)
        .get();

    debugPrint('탈퇴 4-1: myReviews ${myReviews.docs.length}개');

    for (final doc in myReviews.docs) {
      operations.add((batch) {
        batch.update(doc.reference, {
          'isDeleted': true,
          'deletedAt': now,
          'updatedAt': now,
        });
      });
    }

    debugPrint('탈퇴 5: rainbowLetters 조회 시작');
    final letters = await _db
        .collection('rainbowLetters')
        .where('ownerUid', isEqualTo: uid)
        .where('isDeleted', isEqualTo: false)
        .get();

    debugPrint('탈퇴 5-1: rainbowLetters ${letters.docs.length}개');

    for (final letterDoc in letters.docs) {
      operations.add((batch) {
        batch.update(letterDoc.reference, {
          'isDeleted': true,
          'deletedAt': now,
          'updatedAt': now,
        });
      });

      debugPrint('탈퇴 5-2: todakComments 조회 시작 ${letterDoc.id}');
      final todaks = await letterDoc.reference
          .collection('todakComments')
          .get();

      debugPrint('탈퇴 5-3: todakComments ${todaks.docs.length}개');

      for (final todakDoc in todaks.docs) {
        operations.add((batch) {
          batch.update(todakDoc.reference, {
            'isDeleted': true,
            'deletedAt': now,
            'updatedAt': now,
          });
        });
      }
    }

    debugPrint('탈퇴 6: myTodaks collectionGroup 조회 시작');
    final myTodaks = await _db
        .collectionGroup('todakComments')
        .where('writerUid', isEqualTo: uid)
        .get();

    debugPrint('탈퇴 6-1: myTodaks ${myTodaks.docs.length}개');

    for (final doc in myTodaks.docs) {
      operations.add((batch) {
        batch.update(doc.reference, {
          'isDeleted': true,
          'deletedAt': now,
          'updatedAt': now,
        });
      });
    }

    debugPrint('탈퇴 7: favoriteCats 삭제 준비');
    await _addDeleteSubcollectionOperations(
      operations: operations,
      uid: uid,
      collectionName: 'favoriteCats',
    );

    debugPrint('탈퇴 7-1: scraps 삭제 준비');
    await _addDeleteSubcollectionOperations(
      operations: operations,
      uid: uid,
      collectionName: 'scraps',
    );

    debugPrint('탈퇴 7-2: blockedUsers 삭제 준비');
    await _addDeleteSubcollectionOperations(
      operations: operations,
      uid: uid,
      collectionName: 'blockedUsers',
    );

    debugPrint('탈퇴 8: notifications 삭제 준비');
    await _addNotificationDeleteOperations(operations: operations, uid: uid);

    debugPrint('탈퇴 9: commit 시작, 총 작업 ${operations.length}개');
    await _commitOperations(operations);

    debugPrint('탈퇴 9-1: commit 완료');
  }

  static Future<void> _addDeleteSubcollectionOperations({
    required List<void Function(WriteBatch batch)> operations,
    required String uid,
    required String collectionName,
  }) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection(collectionName)
        .get();

    debugPrint('탈퇴 subcollection $collectionName ${snapshot.docs.length}개');

    for (final doc in snapshot.docs) {
      operations.add((batch) {
        batch.delete(doc.reference);
      });
    }
  }

  static Future<void> _addNotificationDeleteOperations({
    required List<void Function(WriteBatch batch)> operations,
    required String uid,
  }) async {
    debugPrint('탈퇴 8-1: 받은 알림 조회 시작');
    final received = await _db
        .collection('notifications')
        .where('receiverUid', isEqualTo: uid)
        .get();

    debugPrint('탈퇴 8-2: 받은 알림 ${received.docs.length}개');

    for (final doc in received.docs) {
      operations.add((batch) {
        batch.delete(doc.reference);
      });
    }

    debugPrint('탈퇴 8-3: 보낸 알림 조회 시작');
    final sent = await _db
        .collection('notifications')
        .where('senderUid', isEqualTo: uid)
        .get();

    debugPrint('탈퇴 8-4: 보낸 알림 ${sent.docs.length}개');

    for (final doc in sent.docs) {
      operations.add((batch) {
        batch.delete(doc.reference);
      });
    }
  }

  static Future<void> _commitOperations(
    List<void Function(WriteBatch batch)> operations,
  ) async {
    for (var i = 0; i < operations.length; i += _batchLimit) {
      final batch = _db.batch();

      final end = (i + _batchLimit > operations.length)
          ? operations.length
          : i + _batchLimit;

      debugPrint('탈퇴 commit: $i ~ ${end - 1}');

      for (final operation in operations.sublist(i, end)) {
        operation(batch);
      }

      await batch.commit();
    }
  }
}

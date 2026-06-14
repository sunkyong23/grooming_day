import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ResetTestData {
  static const adminUid = 'wXmTUngsxYU3uaw73pJrB83OCXl2';

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<void> run() async {
    print('🔥 테스트 데이터 초기화 시작');

    // Storage
    await _deleteStorageFolder('posts');
    await _deleteStorageFolder('catProfiles');
    await _deleteStorageFolder('rainbowLetters');

    // Firestore
    await _deletePosts();
    await _deleteRainbowLetters();

    await _deleteCollection('reports');
    await _deleteCollection('userReports');
    await _deleteCollection('notifications');

    await _deleteCatProfiles();

    await _deleteUsersExceptAdmin();

    await _clearAdminSubCollections();

    print('✅ 테스트 데이터 초기화 완료');
  }

  // ---------------------------
  // POSTS
  // ---------------------------

  static Future<void> _deletePosts() async {
    final snapshot = await _firestore.collection('posts').get();

    for (final post in snapshot.docs) {
      final reviews = await post.reference.collection('reviews').get();

      for (final review in reviews.docs) {
        await review.reference.delete();
      }

      await post.reference.delete();
    }

    print('🗑 posts 삭제 완료');
  }

  // ---------------------------
  // RAINBOW LETTERS
  // ---------------------------

  static Future<void> _deleteRainbowLetters() async {
    final snapshot = await _firestore.collection('rainbowLetters').get();

    for (final letter in snapshot.docs) {
      final comments = await letter.reference.collection('todakComments').get();

      for (final comment in comments.docs) {
        await comment.reference.delete();
      }

      await letter.reference.delete();
    }

    print('🗑 rainbowLetters 삭제 완료');
  }

  // ---------------------------
  // CAT PROFILES
  // ---------------------------

  static Future<void> _deleteCatProfiles() async {
    final snapshot = await _firestore.collection('catProfiles').get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    print('🗑 catProfiles 삭제 완료');
  }

  // ---------------------------
  // USERS
  // ---------------------------

  static Future<void> _deleteUsersExceptAdmin() async {
    final users = await _firestore.collection('users').get();

    for (final user in users.docs) {
      if (user.id == adminUid) continue;

      await _deleteUserSubCollections(user.reference);

      await user.reference.delete();
    }

    print('🗑 테스트 사용자 삭제 완료');
  }

  static Future<void> _clearAdminSubCollections() async {
    final adminRef = _firestore.collection('users').doc(adminUid);

    await _deleteUserSubCollections(adminRef);

    print('🗑 관리자 하위 컬렉션 정리 완료');
  }

  static Future<void> _deleteUserSubCollections(
    DocumentReference userRef,
  ) async {
    final scraps = await userRef.collection('scraps').get();

    for (final doc in scraps.docs) {
      await doc.reference.delete();
    }

    final favorites = await userRef.collection('favoriteCats').get();

    for (final doc in favorites.docs) {
      await doc.reference.delete();
    }

    final blocked = await userRef.collection('blockedUsers').get();

    for (final doc in blocked.docs) {
      await doc.reference.delete();
    }
  }

  // ---------------------------
  // GENERIC COLLECTION DELETE
  // ---------------------------

  static Future<void> _deleteCollection(String collectionName) async {
    final snapshot = await _firestore.collection(collectionName).get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    print('🗑 $collectionName 삭제 완료');
  }

  // ---------------------------
  // STORAGE DELETE
  // ---------------------------

  static Future<void> _deleteStorageFolder(String folderName) async {
    try {
      final ref = _storage.ref(folderName);

      await _deleteFolderRecursively(ref);

      print('🗑 Storage $folderName 삭제 완료');
    } catch (e) {
      print('⚠️ Storage $folderName 삭제 실패: $e');
    }
  }

  static Future<void> _deleteFolderRecursively(Reference ref) async {
    final result = await ref.listAll();

    for (final item in result.items) {
      await item.delete();
    }

    for (final folder in result.prefixes) {
      await _deleteFolderRecursively(folder);
    }
  }
}

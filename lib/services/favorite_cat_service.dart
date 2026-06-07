import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/favorite_cat.dart';

class FavoriteCatService {
  static Future<bool> isFavoriteCat(String catProfileId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteCats')
        .doc(catProfileId)
        .get();

    return doc.exists;
  }

  static Future<List<FavoriteCat>> loadFavoriteCats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteCats')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => FavoriteCat.fromDoc(doc)).toList();
  }

  static Future<void> addFavoriteCat({
    required String catProfileId,
    required String ownerUid,
    required String catName,
    required String catProfileImageUrl,
    required String ownerUserId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteCats')
        .doc(catProfileId)
        .set({
          'catProfileId': catProfileId,
          'ownerUid': ownerUid,
          'catName': catName,
          'catProfileImageUrl': catProfileImageUrl,
          'ownerUserId': ownerUserId,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<void> removeFavoriteCat(String catProfileId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favoriteCats')
        .doc(catProfileId)
        .delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  static Future<void> addFavoriteCat({
    required String catProfileId,
    required String ownerUid,
    required String catName,
    required String catProfileImageUrl,
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

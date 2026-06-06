import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> sendPasswordResetEmail(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future<void> signOut() {
    return FirebaseAuth.instance.signOut();
  }

  static User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }

  static Future<void> registerUser({
    required String email,
    required String password,
    required String userId,
  }) async {
    final userCredential = await signUp(email: email, password: password);

    final uid = userCredential.user!.uid;

    final batch = FirebaseFirestore.instance.batch();

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userIdRef = FirebaseFirestore.instance
        .collection('userIds')
        .doc(userId);

    batch.set(userRef, {
      'uid': uid,
      'email': email,
      'userId': userId,
      'bio': '',
      'profileImageUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isDeleted': false,
      'isSuspended': false,
    });

    batch.set(userIdRef, {
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: 'no-user', message: '로그인된 사용자가 없습니다.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }
}

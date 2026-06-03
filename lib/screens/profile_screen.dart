import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/post.dart';
import 'settings_screen.dart';

import 'login_screen.dart';
import 'edit_profile_screen.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_post_grid.dart';
import '../widgets/settings_tile.dart';
import '../widgets/cat_profile_card.dart';

class ProfileScreen extends StatefulWidget {
  final List<Post> posts;

  const ProfileScreen({super.key, required this.posts});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userId = '로딩중...';

  String profileImageUrl = '';
  File? selectedProfileImage;

  String bio = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> uploadProfileImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        IOSUiSettings(
          title: '프로필 사진 자르기',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile == null) return;

    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      croppedFile.path,
      targetPath,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );

    if (compressedFile == null) return;

    final file = File(compressedFile.path);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(uid)
        .child('profile.jpg');

    await ref.putFile(file);

    final imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profileImageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      selectedProfileImage = file;
      profileImageUrl = imageUrl;
    });
  }

  Future<void> editBio() async {
    final bioController = TextEditingController(text: bio);

    final newBio = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('소개글 수정'),
          content: TextField(
            controller: bioController,
            maxLength: 50,
            decoration: const InputDecoration(hintText: '한줄 소개를 입력해주세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, bioController.text.trim());
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );

    if (newBio == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'bio': newBio,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      bio = newBio;
    });
  }

  Future<void> loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      setState(() {
        userId = doc['userId'];
        profileImageUrl = doc['profileImageUrl'] ?? '';
        bio = doc['bio'] ?? '';
        email = doc['email'] ?? '';
      });
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('계정 탈퇴'),
          content: const Text('정말 탈퇴하시겠습니까?\n모든 정보가 삭제됩니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showReauthDialog();
              },
              child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showReauthDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('본인 확인'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: '비밀번호를 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final user = FirebaseAuth.instance.currentUser;

                if (user == null) return;

                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: passwordController.text.trim(),
                );

                final messenger = ScaffoldMessenger.of(context);

                try {
                  await user.reauthenticateWithCredential(credential);

                  await _deleteAccount();
                } catch (e) {
                  if (!mounted) return;

                  messenger.showSnackBar(
                    const SnackBar(content: Text('비밀번호가 올바르지 않습니다.')),
                  );
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final uid = user.uid;

      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('ownerUid', isEqualTo: uid)
          .get();

      for (final doc in postsSnapshot.docs) {
        final postId = doc.id;

        try {
          await FirebaseStorage.instance.ref('posts/$uid/$postId.jpg').delete();
        } catch (e) {
          // print('게시글 이미지 삭제 실패: $e');
        }

        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .delete();
      }

      try {
        await FirebaseStorage.instance.ref('users/$uid/profile.jpg').delete();
      } catch (e) {
        // print('프로필 이미지 삭제 실패: $e');
      }

      final scrapsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('scraps')
          .get();

      for (final doc in scrapsSnapshot.docs) {
        await doc.reference.delete();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      await user.delete();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      // print('계정 탈퇴 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final myPosts = widget.posts.where((post) => !post.isAsset).toList();
    final scrappedPosts = widget.posts
        .where((post) => post.isScrapped)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: const Text('프로필'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          ProfileHeader(
            userId: userId,
            bio: bio,
            profileImageUrl: profileImageUrl,
            postCount: myPosts.length,
            onProfileImageTap: uploadProfileImage,
            onEditTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      EditProfileScreen(currentUserId: userId, currentBio: bio),
                ),
              );

              if (result != null) {
                setState(() {
                  userId = result['userId'];
                  bio = result['bio'];
                });
              }
            },
          ),

          const SizedBox(height: 24),

          const CatProfileCard(),

          const SizedBox(height: 24),

          const Text(
            '내 게시글',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 12),
          ProfilePostGrid(posts: myPosts),

          const SizedBox(height: 28),

          const Text(
            '스크랩',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 12),

          scrappedPosts.isEmpty
              ? const Text(
                  '아직 스크랩한 게시글이 없어요 🐾',

                  style: TextStyle(color: Color(0xFFB08678)),
                )
              : ProfilePostGrid(posts: scrappedPosts),
          const SizedBox(height: 40),

          SettingsTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    email: email,
                    onDeleteAccountTap: _showDeleteAccountDialog,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

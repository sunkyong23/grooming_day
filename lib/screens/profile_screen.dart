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

                try {
                  await user.reauthenticateWithCredential(credential);

                  await _deleteAccount();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
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
          print('게시글 이미지 삭제 실패: $e');
        }

        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .delete();
      }

      try {
        await FirebaseStorage.instance.ref('users/$uid/profile.jpg').delete();
      } catch (e) {
        print('프로필 이미지 삭제 실패: $e');
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
      print('계정 탈퇴 오류: $e');
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
          Row(
            children: [
              GestureDetector(
                onTap: uploadProfileImage,
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFFFFE2C6),
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: profileImageUrl.isEmpty
                      ? const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF8A756C),
                          size: 30,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '@$userId',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                currentUserId: userId,
                                currentBio: bio,
                              ),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              userId = result['userId'];
                              bio = result['bio'];
                            });
                          }
                        },
                        child: const Text('편집'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    bio.isEmpty ? '소개글을 작성해주세요 🐾' : bio,
                    style: const TextStyle(
                      color: Color(0xFF7A6A5B),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '게시글 ${myPosts.length}개',
                    style: const TextStyle(color: Color(0xFFB08678)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 여기부터 기존 가을이 카드 Container 이어서 두면 됨
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '가을이',

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('오늘도 귀여움으로 하루를 채우는 고양이 🐾'),

          const SizedBox(height: 24),
          const Text(
            '내 게시글',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: myPosts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final post = myPosts[index];

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: post.isAsset
                    ? Image.asset(post.imageUrl, fit: BoxFit.cover)
                    : Image.network(post.imageUrl, fit: BoxFit.cover),
              );
            },
          ),

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
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: scrappedPosts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    final post = scrappedPosts[index];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: post.isAsset
                          ? Image.asset(post.imageUrl, fit: BoxFit.cover)
                          : Image.network(post.imageUrl, fit: BoxFit.cover),
                    );
                  },
                ),
          const SizedBox(height: 40),

          GestureDetector(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: const Row(
                children: [
                  Icon(Icons.settings_rounded, color: Color(0xFF8A756C)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '설정',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3D241E),
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Color(0xFFB08678)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

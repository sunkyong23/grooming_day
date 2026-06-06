import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/post.dart';
import 'settings_screen.dart';

import 'login_screen.dart';
import 'edit_profile_screen.dart';
import '../widgets/profile_header.dart';

import '../widgets/settings_tile.dart';
import '../widgets/cat_profile_card.dart';

import '../services/user_service.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/reauth_dialog.dart';

import '../models/cat_profile.dart';
import '../services/cat_service.dart';

import 'create_cat_screen.dart';

import 'cat_profile_type_select_screen.dart';

class ProfileScreen extends StatefulWidget {
  final List<Post> posts;
  final VoidCallback? onRefreshPosts;

  const ProfileScreen({super.key, required this.posts, this.onRefreshPosts});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userId = '로딩중...';

  String profileImageUrl = '';
  File? selectedProfileImage;

  String bio = '';
  String email = '';

  List<CatProfile> catProfiles = [];

  @override
  void initState() {
    super.initState();
    loadUser();
    loadCatProfiles();
  }

  Future<void> loadCatProfiles() async {
    final cats = await CatService.loadMyCatProfiles();

    if (!mounted) return;

    setState(() {
      catProfiles = cats;
    });
  }

  Future<String?> uploadProfileImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return null;

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

    if (croppedFile == null) return null;

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

    if (compressedFile == null) return null;

    final file = File(compressedFile.path);
    final imageUrl = await UserService.updateProfileImage(file);

    if (imageUrl == null) return null;

    setState(() {
      selectedProfileImage = file;
      profileImageUrl = imageUrl;
    });
    return imageUrl;
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

    await UserService.updateBio(newBio);

    setState(() {
      bio = newBio;
    });
  }

  Future<void> loadUser() async {
    final data = await UserService.loadCurrentUser();

    if (data == null) return;

    setState(() {
      userId = data['userId'] ?? '';
      profileImageUrl = data['profileImageUrl'] ?? '';
      bio = data['bio'] ?? '';
      email = data['email'] ?? '';
    });
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteAccountDialog(onConfirm: _showReauthDialog);
      },
    );
  }

  void _showReauthDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ReauthDialog(
          onConfirm: (password) async {
            final user = FirebaseAuth.instance.currentUser;

            if (user == null) return;

            final credential = EmailAuthProvider.credential(
              email: user.email!,
              password: password,
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
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      await UserService.deleteCurrentUserAccount();

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
    final myPosts = widget.posts;

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
            onEditTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    currentUserId: userId,
                    currentBio: bio,
                    currentProfileImageUrl: profileImageUrl,
                    onProfileImageTap: uploadProfileImage,
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
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '내 고양이',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => catProfiles.isEmpty
                          ? const CatProfileTypeSelectScreen()
                          : const CreateCatScreen(isFromProfile: true),
                    ),
                  );

                  if (result == true) {
                    loadCatProfiles();
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('추가'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          catProfiles.isEmpty
              ? const Text(
                  '등록된 고양이 프로필이 없어요 🐾',
                  style: TextStyle(color: Color(0xFFB08678)),
                )
              : Column(
                  children: catProfiles.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CatProfileCard(
                        cat: cat,
                        onChanged: () async {
                          await loadCatProfiles();
                          widget.onRefreshPosts?.call();
                        },
                      ),
                    );
                  }).toList(),
                ),

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

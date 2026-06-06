import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentUserId;
  final String currentBio;
  final String currentProfileImageUrl;
  final Future<String?> Function() onProfileImageTap;

  const EditProfileScreen({
    super.key,
    required this.currentUserId,
    required this.currentBio,
    required this.currentProfileImageUrl,
    required this.onProfileImageTap,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController userIdController;
  late TextEditingController bioController;
  late String profileImageUrl;

  @override
  void initState() {
    super.initState();
    userIdController = TextEditingController(text: widget.currentUserId);
    bioController = TextEditingController(text: widget.currentBio);
    profileImageUrl = widget.currentProfileImageUrl;
  }

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final newUserId = userIdController.text.trim();
    final newBio = bioController.text.trim();

    final regex = RegExp(r'^[a-zA-Z0-9]+$');

    if (!regex.hasMatch(newUserId)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디는 영어와 숫자만 사용할 수 있습니다.')));
      return;
    }

    final isAvailable = await UserService.isUserIdAvailable(newUserId, uid);

    if (!mounted) return;

    if (!isAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미 사용 중인 아이디입니다.')));
      return;
    }

    await UserService.updateProfile(uid: uid, userId: newUserId, bio: newBio);

    if (!mounted) return;

    Navigator.pop(context, {'userId': newUserId, 'bio': newBio});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
        title: const Text('프로필 편집'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final imageUrl = await widget.onProfileImageTap();

                if (imageUrl == null) return;

                setState(() {
                  profileImageUrl = imageUrl;
                });
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: const Color(0xFFFFF2C6),
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: profileImageUrl.isEmpty
                        ? const Icon(
                            Icons.camera_alt,
                            color: Color(0xFFFFA756),
                            size: 32,
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '프로필 사진 변경',
                    style: TextStyle(fontSize: 13, color: Color(0xFF7A6A5B)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: '아이디',
                hintText: '아이디를 입력해주세요',
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: bioController,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: '소개글',
                hintText: '한줄 소개를 입력해주세요',
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: saveProfile,
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    userIdController = TextEditingController(text: widget.currentUserId);
    bioController = TextEditingController(text: widget.currentBio);
    profileImageUrl = widget.currentProfileImageUrl;
  }

  @override
  void dispose() {
    userIdController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    if (isSaving) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final newUserId = userIdController.text.trim();
    final newBio = bioController.text.trim();

    final regex = RegExp(r'^[a-zA-Z0-9]+$');

    if (newUserId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디를 입력해주세요.')));
      return;
    }

    if (!regex.hasMatch(newUserId)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디는 영어와 숫자만 사용할 수 있습니다.')));
      return;
    }

    setState(() {
      isSaving = true;
    });

    final isAvailable = await UserService.isUserIdAvailable(newUserId, uid);

    if (!mounted) return;

    if (!isAvailable) {
      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미 사용 중인 아이디입니다.')));
      return;
    }

    await UserService.updateProfile(uid: uid, userId: newUserId, bio: newBio);

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    Navigator.pop(context, {'userId': newUserId, 'bio': newBio});
  }

  InputDecoration buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFFB08678), size: 21),
      labelStyle: const TextStyle(
        color: Color(0xFF8C6A5F),
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: const TextStyle(color: Color(0xFFC7ADA4), fontSize: 13),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFFFE4D6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFFFB199), width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget buildProfileImageSection() {
    return GestureDetector(
      onTap: () async {
        final imageUrl = await widget.onProfileImageTap();

        if (imageUrl == null) return;

        setState(() {
          profileImageUrl = imageUrl;
        });
      },
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFFFE2C6),
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        color: Color(0xFFFFA756),
                        size: 38,
                      )
                    : null,
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB199),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '프로필 사진 변경',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8C6A5F),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormSection() {
    return Column(
      children: [
        TextField(
          controller: userIdController,
          readOnly: true,
          enableInteractiveSelection: false,
          decoration:
              buildInputDecoration(
                label: '집사 아이디',
                hint: '집사 아이디는 변경할 수 없어요',
                icon: Icons.alternate_email_rounded,
              ).copyWith(
                fillColor: const Color(0xFFFFF3E7),
                suffixIcon: const Icon(
                  Icons.lock_rounded,
                  size: 18,
                  color: Color(0xFFB08678),
                ),
              ),
        ),

        const SizedBox(height: 18),

        TextField(
          controller: bioController,
          maxLength: 50,
          maxLines: 2,
          decoration: buildInputDecoration(
            label: '소개글',
            hint: '한줄 소개를 입력해주세요',
            icon: Icons.edit_note_rounded,
          ),
        ),
      ],
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isSaving ? null : saveProfile,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFFFA997),
          disabledBackgroundColor: const Color(0xFFE8D6CF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isSaving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                '저장하기',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7F1),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF7F1),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF3D241E)),
          title: const Text(
            '프로필 편집',
            style: TextStyle(
              color: Color(0xFF3D241E),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildProfileImageSection(),

                const SizedBox(height: 34),

                buildFormSection(),

                const SizedBox(height: 28),

                buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

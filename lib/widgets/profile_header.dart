import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String userId;
  final String bio;
  final String profileImageUrl;
  final int postCount;
  final VoidCallback onProfileImageTap;
  final VoidCallback onEditTap;

  const ProfileHeader({
    super.key,
    required this.userId,
    required this.bio,
    required this.profileImageUrl,
    required this.postCount,
    required this.onProfileImageTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onProfileImageTap,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '@$userId',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(onPressed: onEditTap, child: const Text('편집')),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                bio.isEmpty ? '소개글을 작성해주세요 🐾' : bio,
                style: const TextStyle(color: Color(0xFF7A6A5B), fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '게시글 $postCount개',
                style: const TextStyle(color: Color(0xFFB08678)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

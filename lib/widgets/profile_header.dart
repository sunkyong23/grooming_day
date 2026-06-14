import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String userId;
  final String bio;
  final String profileImageUrl;
  final int postCount;
  final VoidCallback onEditTap;

  const ProfileHeader({
    super.key,
    required this.userId,
    required this.bio,
    required this.profileImageUrl,
    required this.postCount,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: const Color(0xFFFFF2C6),
          backgroundImage: profileImageUrl.isNotEmpty
              ? NetworkImage(profileImageUrl)
              : null,
          child: profileImageUrl.isEmpty
              ? const Icon(Icons.camera_alt, color: Color(0xFFFFA756), size: 26)
              : null,
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$userId',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      bio.isEmpty ? '소개글을 작성해주세요 🐾' : bio,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF7A6A5B),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '게시글 $postCount개',
                      style: const TextStyle(
                        color: Color(0xFFB08678),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF7B5146),
                  padding: const EdgeInsets.only(top: 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onEditTap,
                child: const Text(
                  '편집',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

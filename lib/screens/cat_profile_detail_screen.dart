import 'package:flutter/material.dart';

import '../models/cat_profile.dart';

class CatProfileDetailScreen extends StatelessWidget {
  final CatProfile catProfile;

  const CatProfileDetailScreen({super.key, required this.catProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: Text(catProfile.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 56,
                backgroundColor: const Color(0xFFFFE2C6),
                backgroundImage: catProfile.profileImageUrl.isNotEmpty
                    ? NetworkImage(catProfile.profileImageUrl)
                    : null,
                child: catProfile.profileImageUrl.isEmpty
                    ? const Icon(
                        Icons.pets_rounded,
                        size: 36,
                        color: Color(0xFF8A756C),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                catProfile.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D241E),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('성별: ${catProfile.gender}'),
                  const SizedBox(height: 8),
                  Text(
                    '품종: ${catProfile.breed.isEmpty ? '미입력' : catProfile.breed}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '소개: ${catProfile.introduction.isEmpty ? '아직 소개글이 없어요.' : catProfile.introduction}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              '앨범',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3D241E),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Text(
                  '아직 등록된 게시글이 없어요 🐾',
                  style: TextStyle(color: Color(0xFF8A756C)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

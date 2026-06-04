import 'package:flutter/material.dart';

import '../models/cat_profile.dart';

import '../screens/cat_profile_detail_screen.dart';

class CatProfileCard extends StatelessWidget {
  final CatProfile cat;

  const CatProfileCard({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CatProfileDetailScreen(cat: cat)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFFFE2C6),
              backgroundImage: cat.profileImageUrl.isNotEmpty
                  ? NetworkImage(cat.profileImageUrl)
                  : null,
              child: cat.profileImageUrl.isEmpty
                  ? const Icon(Icons.pets_rounded, color: Color(0xFF8A756C))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.introduction.isNotEmpty
                        ? cat.introduction
                        : '오늘도 귀여움으로 하루를 채우는 고양이 🐾',
                    style: const TextStyle(
                      color: Color(0xFF8C6A5F),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB08678)),
          ],
        ),
      ),
    );
  }
}

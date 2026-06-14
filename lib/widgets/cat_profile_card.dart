import 'package:flutter/material.dart';

import '../models/cat_profile.dart';
import '../screens/cat_profile_detail_screen.dart';

class CatProfileCard extends StatelessWidget {
  final CatProfile cat;
  final VoidCallback? onChanged;

  const CatProfileCard({super.key, required this.cat, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CatProfileDetailScreen(cat: cat)),
        );

        if (result == true) {
          onChanged?.call();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFFFE2C6),
              backgroundImage:
                  !cat.isVirtualCat && cat.profileImageUrl.isNotEmpty
                  ? NetworkImage(cat.profileImageUrl)
                  : null,
              child: cat.isVirtualCat
                  ? Padding(
                      padding: const EdgeInsets.all(11),
                      child: Image.asset(
                        'assets/icons/today_cat.png',
                        fit: BoxFit.contain,
                      ),
                    )
                  : cat.profileImageUrl.isEmpty
                  ? const Icon(Icons.pets_rounded, color: Color(0xFF8A756C))
                  : null,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          cat.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (cat.isHidden) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE9DE),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '숨김',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB08678),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 2),

                  Text(
                    cat.introduction.isNotEmpty
                        ? cat.introduction
                        : cat.isVirtualCat
                        ? '고양이를 사랑하는 랜선집사예요'
                        : '오늘도 귀여움으로 하루를 채우는 고양이 🐾',
                    style: const TextStyle(
                      color: Color(0xFF8C6A5F),
                      fontSize: 13,
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

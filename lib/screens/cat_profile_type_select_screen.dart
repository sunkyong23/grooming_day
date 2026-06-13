import 'package:flutter/material.dart';

import 'create_cat_screen.dart';
import 'create_virtual_cat_screen.dart';

class CatProfileTypeSelectScreen extends StatelessWidget {
  const CatProfileTypeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),

              const Text(
                '어떤 프로필로 시작할까요?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4A2B22),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                '그루밍데이는 고양이를 키우는 집사도,\n고양이를 좋아하는 랜선집사도 함께할 수 있어요.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF8A756C),
                ),
              ),

              const SizedBox(height: 28),

              _typeCard(
                context: context,
                emoji: '🐱',
                title: '나의 고양이',
                subtitle: '반려중인 고양이 이름, 생일, 성격을 직접 등록해요.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateCatScreen()),
                  );
                },
              ),

              const SizedBox(height: 18),

              _typeCard(
                context: context,
                emoji: '💻',
                title: '랜선집사',
                subtitle: '고양이가 없어도 그루밍데이를 함께 즐길 수 있어요.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateVirtualCatScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE9DE),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 34)),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4A2B22),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Color(0xFF8C6A5F),
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

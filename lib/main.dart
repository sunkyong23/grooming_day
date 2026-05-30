import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const GroomingDayApp());
}

class GroomingDayApp extends StatelessWidget {
  const GroomingDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset('assets/images/splash.png', fit: BoxFit.cover),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<String> tags = const [
    '오늘의 😺',
    '아깽이',
    '어른신',
    '장난꾸러기',
    '사랑스러운',
    '귀여워',
    '행복해',
    '일상',
    '평온한하루',
    '식빵굽기',
    '발라당',
    '심기불편',
    '사고뭉치',
    '정말못말려',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 120),
          children: [
            const Header(),
            const SizedBox(height: 22),
            const SoftDivider(),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: tags.map((tag) => TagChip(text: tag)).toList(),
            ),
            const SizedBox(height: 24),
            const CatPostCard(
              imagePath: 'assets/images/cat1.png',
              caption: '크아아아앙!!!! 내 하품을 받아라 ♡',
              likes: 72,
              tagText: '#귀여워   #일상   #평온한하루',
            ),
            const SizedBox(height: 18),
            const CatPostCard(
              imagePath: 'assets/images/cat2.png',
              caption: '노곤하당',
              likes: 25,
              tagText: '#귀여워   #일상',
            ),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '그루밍데이',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF351A14),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '오늘도 너와 함께하는 하루',
                style: TextStyle(fontSize: 16, color: Color(0xFF5E3D35)),
              ),
            ],
          ),
        ),
        HeaderIcon(icon: Icons.notifications_none_rounded),
        SizedBox(width: 10),
        HeaderIcon(icon: Icons.photo_camera_outlined),
      ],
    );
  }
}

class HeaderIcon extends StatelessWidget {
  final IconData icon;

  const HeaderIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEACB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFF7A4A42), size: 23),
    );
  }
}

class SoftDivider extends StatelessWidget {
  const SoftDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0D9),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Center(
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFFFFC48E),
          size: 24,
        ),
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  final String text;

  const TagChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final bool selected = text.contains('오늘의');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFE4DE) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? const Color(0xFFFFA09A) : const Color(0xFFF5E5DD),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? const Color(0xFFE57373) : const Color(0xFF5D3B34),
        ),
      ),
    );
  }
}

class CatPostCard extends StatelessWidget {
  final String imagePath;
  final String caption;
  final int likes;
  final String tagText;

  const CatPostCard({
    super.key,
    required this.imagePath,
    required this.caption,
    required this.likes,
    required this.tagText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB58A7B).withOpacity(0.13),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: Color(0xFFFFE2C6),
                  child: Text('🐱', style: TextStyle(fontSize: 17)),
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '가을이',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3D241E),
                        ),
                      ),
                      Text(
                        'groomingday',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB08678),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '2026.05.25',
                  style: TextStyle(fontSize: 10, color: Color(0xFFC9AFA7)),
                ),
                SizedBox(width: 12),
                Icon(Icons.more_horiz, size: 21, color: Color(0xFF9A6B60)),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        caption,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5A372F),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.bookmark_border_rounded,
                      color: Color(0xFF9A6B60),
                      size: 23,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      '감상평  $likes',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFC0A39A),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      tagText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFE09086),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavItem(icon: Icons.home_rounded, label: '홈', active: true),
          NavItem(icon: Icons.search_rounded, label: '탐색'),
          AddButton(),
          NavItem(icon: Icons.bookmark_rounded, label: '꾹꾹'),
          NavItem(icon: Icons.pets_rounded, label: '프로필'),
        ],
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
        color: Color(0xFFFFDFAF),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add_rounded, size: 34, color: Color(0xFF4A2B22)),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF8A4F45) : const Color(0xFF6A443B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w900 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 50, 28, 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              const Icon(
                Icons.pets_rounded,
                size: 72,
                color: Color(0xFF5A2C24),
              ),

              const SizedBox(height: 18),

              const Text(
                '그루밍데이',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF351A14),
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'grooming day',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                  color: Color(0xFF9B746A),
                ),
              ),

              const Spacer(flex: 2),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB58A7B).withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const LoginInput(
                      icon: Icons.person_outline_rounded,
                      label: '아이디',
                      hint: '아이디를 입력해주세요',
                    ),

                    const SizedBox(height: 24),

                    const LoginInput(
                      icon: Icons.lock_outline_rounded,
                      label: '비밀번호',
                      hint: '비밀번호를 입력해주세요',
                      obscure: true,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE89078),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '집사 입장하기',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE89078),
                          side: const BorderSide(
                            color: Color(0xFFE89078),
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          '처음 오셨나요? 집사 등록하기',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              TextButton(
                onPressed: () {},
                child: const Text(
                  '비밀번호를 잊으셨나요?',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6A352C),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginInput extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final bool obscure;

  const LoginInput({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF6A352C), size: 26),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF351A14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFD0B8AE)),
            filled: true,
            fillColor: const Color(0xFFFFF4EC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            suffixIcon: obscure
                ? const Icon(
                    Icons.visibility_off_outlined,
                    color: Color(0xFF9B746A),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF2D6C8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF2D6C8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE89078),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

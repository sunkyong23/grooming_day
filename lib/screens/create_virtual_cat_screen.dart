import 'package:flutter/material.dart';

import '../services/cat_service.dart';
import 'home_screen.dart';

class CreateVirtualCatScreen extends StatefulWidget {
  const CreateVirtualCatScreen({super.key});

  @override
  State<CreateVirtualCatScreen> createState() => _CreateVirtualCatScreenState();
}

class _CreateVirtualCatScreenState extends State<CreateVirtualCatScreen> {
  final introductionController = TextEditingController();
  bool isSubmitting = false;

  @override
  void dispose() {
    introductionController.dispose();
    super.dispose();
  }

  Future<void> submitVirtualCatProfile() async {
    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    await CatService.createCat(
      name: '랜선집사',
      breed: '',
      gender: '',
      birthDate: null,
      introduction: introductionController.text.trim().isEmpty
          ? '고양이를 사랑하는 랜선집사예요'
          : introductionController.text.trim(),
      personalityTags: const [],
      isVirtualCat: true,
      imageFile: null,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('랜선집사 프로필이 등록되었어요 😺')));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: const Text('랜선집사 프로필 만들기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 112,
              height: 112,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE9DE),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Image.asset(
                  'assets/icons/today_cat.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '랜선집사',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF4A2B22),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              '고양이가 없어도 괜찮아요.\n좋아하는 마음만으로도 충분해요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF8C6A5F),
              ),
            ),

            const SizedBox(height: 28),

            TextField(
              controller: introductionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '한줄 소개',
                hintText: '예: 고양이 사진 보는 게 하루의 행복이에요 🐾',
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitVirtualCatProfile,
                child: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('랜선집사 프로필 만들기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

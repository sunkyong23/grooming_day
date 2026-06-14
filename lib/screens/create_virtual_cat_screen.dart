import 'package:flutter/material.dart';

import '../services/cat_service.dart';
import 'main_tab_screen.dart';

class CreateVirtualCatScreen extends StatefulWidget {
  const CreateVirtualCatScreen({super.key});

  @override
  State<CreateVirtualCatScreen> createState() => _CreateVirtualCatScreenState();
}

class _CreateVirtualCatScreenState extends State<CreateVirtualCatScreen> {
  final introductionController = TextEditingController();
  bool isSubmitting = false;

  InputDecoration inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFD0C2BA), fontSize: 16),
      filled: true,
      fillColor: const Color(0xFFFFF7F1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFF0D5CA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE8A58C), width: 2),
      ),
    );
  }

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
      MaterialPageRoute(builder: (_) => const MainTabScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '랜선집사 프로필 만들기',
          style: TextStyle(
            color: Color(0xFF5C4033),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 36),

            Container(
              width: 118,
              height: 118,
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

            const SizedBox(height: 26),

            const Text(
              '랜선집사',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFF5C4033),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              '고양이가 없어도 괜찮아요.\n좋아하는 마음만으로도 충분해요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF8A756C),
              ),
            ),

            const SizedBox(height: 48),

            TextField(
              controller: introductionController,
              maxLines: 1,
              cursorColor: const Color(0xFF5C4033),
              decoration: inputDecoration('한줄 소개를 입력해주세요 🐾'),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitVirtualCatProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD9C9),
                  foregroundColor: const Color(0xFF5C4033),
                  disabledBackgroundColor: const Color(0xFFE8D8D0),
                  disabledForegroundColor: const Color(0xFF9A8E87),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF5C4033),
                        ),
                      )
                    : const Text(
                        '랜선집사 프로필 만들기',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

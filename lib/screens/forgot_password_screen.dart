import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendResetEmail() async {
    setState(() {
      isLoading = true;
    });

    final messenger = ScaffoldMessenger.of(context);

    try {
      await AuthService.sendPasswordResetEmail(emailController.text.trim());

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text('비밀번호 재설정 메일을 발송했습니다.')),
      );
    } on FirebaseAuthException catch (e) {
      String message = '메일 발송에 실패했습니다.';

      if (e.code == 'invalid-email') {
        message = '올바른 이메일 형식이 아닙니다.';
      }

      if (!mounted) return;

      messenger.showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
          '비밀번호 재설정',
          style: TextStyle(
            color: Color(0xFF5C4033),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 60),

            const Text(
              '가입한 이메일을 입력해주세요.\n비밀번호 재설정 링크를\n이메일로 보내드릴게요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF8A756C),
              ),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              cursorColor: Color(0xFF5C4033),
              decoration: InputDecoration(
                hintText: '이메일',
                hintStyle: const TextStyle(
                  color: Color(0xFFD0C2BA),
                  fontSize: 16,
                ),
                filled: true,
                fillColor: const Color(0xFFFFF7F1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFF0D5CA)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: Color(0xFFE8A58C),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            SizedBox(
              width: 230,
              height: 58,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendResetEmail,
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
                child: Text(
                  isLoading ? '발송 중...' : '재설정 메일 보내기',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

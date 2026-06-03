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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        title: const Text('비밀번호 재설정'),
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Text(
              '가입한 이메일을 입력해주세요.\n비밀번호 재설정 메일을 보내드릴게요.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: '이메일'),
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                      });

                      final messenger = ScaffoldMessenger.of(context);

                      try {
                        await AuthService.sendPasswordResetEmail(
                          emailController.text.trim(),
                        );

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

                        messenger.showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
              child: Text(isLoading ? '발송 중...' : '재설정 메일 보내기'),
            ),
          ],
        ),
      ),
    );
  }
}

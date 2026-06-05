import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'terms_screen.dart';
import 'privacy_policy_screen.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';

import 'cat_profile_type_select_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userIdController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isTermsAgreed = false;
  bool isPrivacyAgreed = false;

  bool isLoading = false;

  Future<void> register() async {
    if (isLoading) return;
    if (!isTermsAgreed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이용약관에 동의해주세요.')));
      return;
    }

    if (!isPrivacyAgreed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('개인정보 처리방침에 동의해주세요.')));
      return;
    }

    final userId = userIdController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (userId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디를 입력해주세요.')));
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일을 입력해주세요.')));
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호를 입력해주세요.')));
      return;
    }

    if (confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호 확인을 입력해주세요.')));
      return;
    }

    final regex = RegExp(r'^[a-zA-Z0-9]+$');

    if (!regex.hasMatch(userId)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디는 영어와 숫자만 사용할 수 있습니다.')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final isDuplicated = await UserService.isUserIdDuplicated(userId);

      if (isDuplicated) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이미 사용 중인 아이디입니다.')));

        return;
      }

      await AuthService.registerUser(
        email: email,
        password: password,
        userId: userId,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CatProfileTypeSelectScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = '회원가입 중 오류가 발생했습니다.';

      if (e.code == 'invalid-email') {
        message = '이메일 형식이 올바르지 않습니다.';
      } else if (e.code == 'email-already-in-use') {
        message = '이미 사용 중인 이메일입니다.';
      } else if (e.code == 'weak-password') {
        message = '비밀번호는 6자 이상 입력해주세요.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
        title: const Text('집사 등록하기'),
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              TextField(
                controller: userIdController,
                decoration: const InputDecoration(hintText: '아이디'),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: '이메일'),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: '비밀번호 (6자 이상)'),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: '비밀번호 확인'),
              ),

              Row(
                children: [
                  Checkbox(
                    value: isTermsAgreed,
                    onChanged: (value) {
                      setState(() {
                        isTermsAgreed = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '이용약관에 동의합니다. (필수)',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Checkbox(
                    value: isPrivacyAgreed,
                    onChanged: (value) {
                      setState(() {
                        isPrivacyAgreed = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '개인정보 처리방침에 동의합니다. (필수)',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: isLoading ? null : register,
                child: Text(isLoading ? '가입 중...' : '집사 등록 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

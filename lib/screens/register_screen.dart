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
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFE8A58C), width: 2),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    userIdController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

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

  Widget agreementRow({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String text,
    required VoidCallback onViewTap,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          activeColor: const Color(0xFFE8A58C),
          checkColor: Colors.white,
          side: const BorderSide(color: Color(0xFF8A756C), width: 1.5),
          onChanged: onChanged,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              onChanged(!value);
            },
            behavior: HitTestBehavior.opaque,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5C4033),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onViewTap,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const Icon(
            Icons.chevron_right_rounded,
            size: 24,
            color: Color(0xFF8A756C),
          ),
        ),
      ],
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
          '집사 등록하기',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 56),

              TextField(
                controller: userIdController,
                cursorColor: const Color(0xFF5C4033),
                decoration: inputDecoration('아이디'),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                cursorColor: const Color(0xFF5C4033),
                decoration: inputDecoration('이메일'),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: passwordController,
                obscureText: true,
                cursorColor: const Color(0xFF5C4033),
                decoration: inputDecoration('비밀번호 (6자 이상)'),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                cursorColor: const Color(0xFF5C4033),
                decoration: inputDecoration('비밀번호 확인'),
              ),

              const SizedBox(height: 18),

              agreementRow(
                value: isTermsAgreed,
                onChanged: (value) {
                  setState(() {
                    isTermsAgreed = value ?? false;
                  });
                },
                text: '이용약관 동의 (필수)',
                onViewTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsScreen()),
                  );
                },
              ),

              agreementRow(
                value: isPrivacyAgreed,
                onChanged: (value) {
                  setState(() {
                    isPrivacyAgreed = value ?? false;
                  });
                },
                text: '개인정보 처리방침 동의 (필수)',
                onViewTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: 230,
                height: 58,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
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
                    isLoading ? '가입 중...' : '집사 등록하기',
                    style: const TextStyle(
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
      ),
    );
  }
}

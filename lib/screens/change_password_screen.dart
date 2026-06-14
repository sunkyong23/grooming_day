import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요.')));
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('새 비밀번호는 6자 이상이어야 합니다.')));
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('새 비밀번호가 일치하지 않습니다.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await AuthService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호가 변경되었습니다.')));

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String message = '비밀번호 변경에 실패했습니다.';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = '현재 비밀번호가 올바르지 않습니다.';
      } else if (e.code == 'weak-password') {
        message = '새 비밀번호가 너무 약합니다.';
      } else if (e.code == 'requires-recent-login') {
        message = '보안을 위해 다시 로그인 후 시도해주세요.';
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

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFC3ADA3), fontSize: 15),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.92),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFFFD9C9), width: 1.5),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5C4033),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: true,
          cursorColor: const Color(0xFF5C4033),
          style: const TextStyle(
            color: Color(0xFF3D241E),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          decoration: _inputDecoration(hintText),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '비밀번호 변경',
          style: TextStyle(
            color: Color(0xFF4A2F26),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(24, 34, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _passwordField(
              controller: currentPasswordController,
              label: '현재 비밀번호',
              hintText: '현재 비밀번호를 입력해주세요',
            ),
            const SizedBox(height: 20),
            _passwordField(
              controller: newPasswordController,
              label: '새 비밀번호',
              hintText: '6자 이상 입력해주세요',
            ),
            const SizedBox(height: 20),
            _passwordField(
              controller: confirmPasswordController,
              label: '새 비밀번호 확인',
              hintText: '새 비밀번호를 한 번 더 입력해주세요',
            ),
            const SizedBox(height: 34),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD9C9),
                  foregroundColor: const Color(0xFF5C4033),
                  disabledBackgroundColor: const Color(0xFFE8D8D0),
                  disabledForegroundColor: const Color(0xFF9A8E87),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF5C4033),
                        ),
                      )
                    : const Text(
                        '비밀번호 변경하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import '../services/account_delete_service.dart';

class DeleteAccountScreen extends StatefulWidget {
  final String email;

  const DeleteAccountScreen({super.key, required this.email});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  Future<void> deleteAccount() async {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      showSnackBar('비밀번호를 입력해주세요.');
      return;
    }

    final confirm = await showConfirmDialog();

    if (confirm != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      await AccountDeleteService.deleteAccount(
        email: widget.email,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-login-credentials') {
        showSnackBar('비밀번호가 올바르지 않습니다.');
      } else if (e.code == 'requires-recent-login') {
        showSnackBar('보안을 위해 다시 로그인 후 탈퇴를 진행해주세요.');
      } else {
        showSnackBar('계정 탈퇴 중 오류가 발생했습니다.');
      }
    } catch (e) {
      debugPrint('계정 탈퇴 오류: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showSnackBar('$e');
    }
  }

  Future<bool?> showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFF8F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text(
            '정말 탈퇴하시겠어요?',
            style: TextStyle(
              color: Color(0xFF3D241E),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            '계정 탈퇴 시 모든 고양이 프로필, 게시글, 감상평, 무지개별 편지, 꾹꾹 정보가 삭제되며 복구할 수 없습니다.',
            style: TextStyle(
              color: Color(0xFF5C4033),
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                '취소',
                style: TextStyle(color: Color(0xFF8A756C)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                '탈퇴하기',
                style: TextStyle(
                  color: Color(0xFFFF5A5A),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF5C4033),
        behavior: SnackBarBehavior.floating,
      ),
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
          '계정 탈퇴',
          style: TextStyle(
            color: Color(0xFF4A2F26),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFF0D5CA)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '탈퇴 전 꼭 확인해주세요',
                    style: TextStyle(
                      color: Color(0xFF3D241E),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 14),
                  _WarningText('내 계정 정보가 삭제됩니다.'),
                  _WarningText('내 고양이 프로필이 삭제됩니다.'),
                  _WarningText('내 게시글과 감상평이 삭제됩니다.'),
                  _WarningText('무지개별 편지와 토닥토닥이 삭제됩니다.'),
                  _WarningText('꾹꾹 고양이, 꾹꾹 게시글, 알림 정보가 삭제됩니다.'),
                  SizedBox(height: 12),
                  Text(
                    '삭제된 데이터는 복구할 수 없습니다.',
                    style: TextStyle(
                      color: Color(0xFFFF5A5A),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            const Text(
              '본인 확인을 위해 비밀번호를 입력해주세요.',
              style: TextStyle(
                color: Color(0xFF5C4033),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              cursorColor: const Color(0xFF8A5A44),
              decoration: InputDecoration(
                hintText: '비밀번호',
                hintStyle: const TextStyle(
                  color: Color(0xFFD0C2BA),
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFFB08678),
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFFF0D5CA)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color(0xFFE8A58C),
                    width: 1.4,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : deleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5A5A),
                  disabledBackgroundColor: const Color(0xFFE8C8C2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '계정 탈퇴하기',
                        style: TextStyle(
                          color: Colors.white,
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

class _WarningText extends StatelessWidget {
  final String text;

  const _WarningText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: Color(0xFFFF8A7A),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF5C4033),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

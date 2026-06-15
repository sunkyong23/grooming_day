import 'package:flutter/material.dart';

class ReauthDialog extends StatefulWidget {
  final Future<void> Function(String password) onConfirm;

  const ReauthDialog({super.key, required this.onConfirm});

  @override
  State<ReauthDialog> createState() => _ReauthDialogState();
}

class _ReauthDialogState extends State<ReauthDialog> {
  final passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFF8F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text(
        '본인 확인',
        style: TextStyle(
          color: Color(0xFF3D241E),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: TextField(
        controller: passwordController,
        obscureText: true,
        cursorColor: const Color(0xFF5C4033),
        style: const TextStyle(
          color: Color(0xFF3D241E),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: '비밀번호를 입력해주세요',
          hintStyle: const TextStyle(color: Color(0xFFC3ADA3), fontSize: 15),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFF0D5CA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE8A58C), width: 2),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            '취소',
            style: TextStyle(
              color: Color(0xFF8A756C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            final password = passwordController.text.trim();

            Navigator.pop(context);
            await widget.onConfirm(password);
          },
          child: const Text(
            '확인',
            style: TextStyle(
              color: Color(0xFF5C4033),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

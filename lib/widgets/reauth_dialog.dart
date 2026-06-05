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
      title: const Text('본인 확인'),
      content: TextField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(hintText: '비밀번호를 입력하세요'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () async {
            final password = passwordController.text.trim();

            Navigator.pop(context);
            await widget.onConfirm(password);
          },
          child: const Text('확인'),
        ),
      ],
    );
  }
}

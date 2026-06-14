import 'package:flutter/material.dart';

class DeleteAccountDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteAccountDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFFF8F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text(
        '계정 탈퇴',
        style: TextStyle(
          color: Color(0xFF3D241E),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: const Text(
        '탈퇴 시 작성한 게시글, 감상평,\n고양이 프로필 정보가 모두 삭제됩니다.\n\n정말 탈퇴하시겠어요?',
        style: TextStyle(color: Color(0xFF5C4033), fontSize: 15, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('취소', style: TextStyle(color: Color(0xFF8A756C))),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text(
            '탈퇴',
            style: TextStyle(
              color: Color(0xFFFF5A5A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

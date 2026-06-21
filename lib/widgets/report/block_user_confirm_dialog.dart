import 'package:flutter/material.dart';

Future<bool> showBlockUserConfirmDialog({
  required BuildContext context,
  required String userId,
}) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFFFFF8F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      title: const Text(
        '사용자 차단',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Color(0xFF5C4033),
        ),
      ),
      content: Text(
        '@$userId 님을 차단할까요?\n\n'
        '차단하면 이 사용자의 게시글이\n'
        '더 이상 보이지 않아요.',
        style: const TextStyle(
          fontSize: 16,
          height: 1.55,
          color: Color(0xFF5A372F),
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 20, bottom: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text(
            '취소',
            style: TextStyle(
              color: Color(0xFF8A756C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text(
            '차단',
            style: TextStyle(
              color: Color(0xFFFF7A7A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );

  return confirm == true;
}

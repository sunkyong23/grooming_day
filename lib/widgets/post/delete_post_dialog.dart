import 'package:flutter/material.dart';

Future<bool> showDeletePostConfirmDialog({
  required BuildContext context,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFFFFF8F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        actionsPadding: const EdgeInsets.only(right: 20, bottom: 12),
        title: const Text(
          '게시글 삭제',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF5A372F),
          ),
        ),
        content: const Text(
          '삭제 후에는 되돌릴 수 없어요.',
          style: TextStyle(fontSize: 16, color: Color(0xFF8A756C), height: 1.5),
        ),
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
              '삭제',
              style: TextStyle(
                color: Color(0xFFFF7A7A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    },
  );

  return shouldDelete == true;
}

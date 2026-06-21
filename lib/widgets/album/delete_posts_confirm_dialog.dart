import 'package:flutter/material.dart';

Future<bool> showDeletePostsConfirmDialog({
  required BuildContext context,
  required int count,
}) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFFFFF8F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text(
        '게시글 삭제',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF5C4033),
        ),
      ),
      content: Text(
        '$count개의 게시글을 삭제할까요?\n삭제 후에는 되돌릴 수 없어요.',
        style: const TextStyle(
          fontSize: 16,
          height: 1.45,
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
            '삭제',
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

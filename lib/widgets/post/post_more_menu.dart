import 'package:flutter/material.dart';

import '../../models/post.dart';

Future<void> showPostMoreMenu({
  required BuildContext context,
  required Post post,
  required bool isMyPost,
  required VoidCallback onEditTap,
  required VoidCallback onDeleteTap,
  required VoidCallback onReportTap,
  required VoidCallback onUserReportTap,
  required Future<void> Function() onBlockTap,
}) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFFFFF7F1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (bottomSheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMyPost) ...[
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('수정'),
                  textColor: const Color(0xFF5A372F),
                  iconColor: const Color(0xFF9A6B60),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    onEditTap();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('삭제'),
                  textColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    onDeleteTap();
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('게시글 신고'),
                  textColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    onReportTap();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('사용자 신고'),
                  textColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    onUserReportTap();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_off_outlined),
                  title: const Text('사용자 차단'),
                  textColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    await onBlockTap();
                  },
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

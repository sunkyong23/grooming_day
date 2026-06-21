import 'package:flutter/material.dart';

import '../tag_chip.dart';

Future<void> showTagBottomSheet({
  required BuildContext context,
  required List<String> tags,
  required String? selectedTag,
  required Future<void> Function(String tag) onTagTap,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFFFFF7F1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (bottomSheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '태그 전체보기',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3D241E),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
              childAspectRatio: 2.5,
              children: tags.map((tag) {
                return GestureDetector(
                  onTap: () async {
                    await onTagTap(tag);

                    if (bottomSheetContext.mounted) {
                      Navigator.pop(bottomSheetContext);
                    }
                  },
                  child: TagChip(
                    key: ValueKey('sheet_$tag'),
                    text: tag,
                    isSelected: selectedTag == tag,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    },
  );
}

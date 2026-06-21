import 'package:flutter/material.dart';

import '../header.dart';
import '../tag_chip.dart';
import 'tag_bottom_sheet.dart';

class HomeTagHeader extends StatelessWidget {
  final List<String> tags;
  final String? selectedFeedTag;
  final ScrollController tagScrollController;
  final VoidCallback onCameraTap;
  final Future<void> Function(String tag) onTagTap;

  const HomeTagHeader({
    super.key,
    required this.tags,
    required this.selectedFeedTag,
    required this.tagScrollController,
    required this.onCameraTap,
    required this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(onCameraTap: onCameraTap),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0E3DC)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: tagScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: tags.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            await onTagTap(tag);
                          },
                          child: TagChip(
                            key: ValueKey(tag),
                            text: tag,
                            isSelected: selectedFeedTag == tag,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  showTagBottomSheet(
                    context: context,
                    tags: tags,
                    selectedTag: selectedFeedTag,
                    onTagTap: onTagTap,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    size: 20,
                    color: Color(0xFF8A756C),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

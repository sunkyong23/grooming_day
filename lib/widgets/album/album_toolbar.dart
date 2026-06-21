import 'package:flutter/material.dart';

class AlbumToolbar extends StatelessWidget {
  final String selectedSort;
  final bool isGridView;
  final ValueChanged<String> onSortSelected;
  final ValueChanged<bool> onViewChanged;

  const AlbumToolbar({
    super.key,
    required this.selectedSort,
    required this.isGridView,
    required this.onSortSelected,
    required this.onViewChanged,
  });

  String get selectedSortLabel {
    if (selectedSort == 'latest') return '최신순';
    if (selectedSort == 'oldest') return '오래된 순';
    if (selectedSort == 'scrap') return '스크랩 많은 순';
    if (selectedSort == 'review') return '감상평 많은 순';
    return '최신순';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
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
                          _SortOption(
                            label: '최신순',
                            value: 'latest',
                            selectedSort: selectedSort,
                            onTap: (value) {
                              Navigator.pop(bottomSheetContext);
                              onSortSelected(value);
                            },
                          ),
                          _SortOption(
                            label: '오래된 순',
                            value: 'oldest',
                            selectedSort: selectedSort,
                            onTap: (value) {
                              Navigator.pop(bottomSheetContext);
                              onSortSelected(value);
                            },
                          ),
                          _SortOption(
                            label: '스크랩 많은 순',
                            value: 'scrap',
                            selectedSort: selectedSort,
                            onTap: (value) {
                              Navigator.pop(bottomSheetContext);
                              onSortSelected(value);
                            },
                          ),
                          _SortOption(
                            label: '감상평 많은 순',
                            value: 'review',
                            selectedSort: selectedSort,
                            onTap: (value) {
                              Navigator.pop(bottomSheetContext);
                              onSortSelected(value);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedSortLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9A6B60),
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF9A6B60),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => onViewChanged(true),
            child: Icon(
              Icons.grid_view_rounded,
              size: 22,
              color: isGridView
                  ? const Color(0xFF8A5A44)
                  : const Color(0xFFC9B8AF),
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => onViewChanged(false),
            child: Icon(
              Icons.view_agenda_outlined,
              size: 22,
              color: !isGridView
                  ? const Color(0xFF8A5A44)
                  : const Color(0xFFC9B8AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final String value;
  final String selectedSort;
  final ValueChanged<String> onTap;

  const _SortOption({
    required this.label,
    required this.value,
    required this.selectedSort,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedSort == value;

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          color: isSelected ? const Color(0xFF6F3F2E) : const Color(0xFF8A5A44),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: Color(0xFFFF8A7A))
          : null,
      onTap: () => onTap(value),
    );
  }
}

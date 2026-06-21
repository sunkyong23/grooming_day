import 'package:flutter/material.dart';

class AlbumTabs extends StatelessWidget {
  final int selectedAlbumTab;
  final ValueChanged<int> onTabSelected;

  const AlbumTabs({
    super.key,
    required this.selectedAlbumTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            _AlbumTab(
              label: '내 앨범',
              index: 0,
              isSelected: selectedAlbumTab == 0,
              onTap: onTabSelected,
            ),
            _AlbumTab(
              label: '꾹꾹 앨범',
              index: 1,
              isSelected: selectedAlbumTab == 1,
              onTap: onTabSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumTab extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const _AlbumTab({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFBE5D8) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3D241E),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/cat_profile.dart';
import '../../screens/home_screen.dart';

class CatFilterArea extends StatelessWidget {
  final bool isLoadingCats;
  final AnimationController loadingController;
  final List<CatProfile> catProfiles;
  final String? selectedCatProfileId;
  final ValueChanged<String?> onCatSelected;

  const CatFilterArea({
    super.key,
    required this.isLoadingCats,
    required this.loadingController,
    required this.catProfiles,
    required this.selectedCatProfileId,
    required this.onCatSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingCats) {
      return SizedBox(
        height: 34,
        child: Center(child: ThreeDotLoading(controller: loadingController)),
      );
    }

    return SizedBox(
      height: 38,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _CatFilterChip(
              label: '전체',
              isSelected: selectedCatProfileId == null,
              onTap: () => onCatSelected(null),
            ),
            ...catProfiles.map((cat) {
              return _CatFilterChip(
                label: cat.name,
                isSelected: selectedCatProfileId == cat.id,
                onTap: () => onCatSelected(cat.id),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CatFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CatFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 7)
            : EdgeInsets.zero,
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFFFE4D6),
                borderRadius: BorderRadius.circular(999),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected
                ? const Color(0xFF6F3F2E)
                : const Color(0xFFC0A39A),
          ),
        ),
      ),
    );
  }
}

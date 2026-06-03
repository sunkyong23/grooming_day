import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String text;
  final bool isSelected;

  const TagChip({super.key, required this.text, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF0E7) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: -0.3,
              color: isSelected
                  ? const Color(0xFF3D241E)
                  : const Color(0xFF6A554B),
            ),
          ),
          if (text == '오늘의') ...[
            const SizedBox(width: 4),
            Image.asset('assets/icons/today_cat.png', width: 16, height: 16),
          ],
        ],
      ),
    );
  }
}

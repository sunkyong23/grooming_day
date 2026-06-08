import 'package:flutter/material.dart';

import '../models/post.dart';
import 'add_button.dart';
import 'nav_item.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Function(Post, bool) onPostCreated;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onPostCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E7),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => onTap(0),
            child: NavItem(
              icon: Icons.home_rounded,
              label: '홈',
              active: currentIndex == 0,
            ),
          ),
          GestureDetector(
            onTap: () => onTap(1),
            child: NavItem(
              icon: Icons.search_rounded,
              label: '탐색',
              active: currentIndex == 1,
            ),
          ),
          AddButton(onPostCreated: onPostCreated),
          GestureDetector(
            onTap: () => onTap(2),
            child: NavItem(
              icon: Icons.photo_library_rounded,
              label: '앨범',
              active: currentIndex == 2,
            ),
          ),
          GestureDetector(
            onTap: () => onTap(3),
            child: NavItem(
              icon: Icons.pets_rounded,
              label: '프로필',
              active: currentIndex == 3,
            ),
          ),
        ],
      ),
    );
  }
}

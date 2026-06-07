import 'package:flutter/material.dart';

import '../models/post.dart';
import 'add_button.dart';
import 'nav_item.dart';

import '../screens/album_screen.dart';
import '../screens/profile_screen.dart';

import '../screens/search_screen.dart';

class BottomNavBar extends StatelessWidget {
  final Function(Post) onPostCreated;
  final VoidCallback onRefreshPosts;
  final List<Post> posts;

  const BottomNavBar({
    super.key,
    required this.onPostCreated,
    required this.onRefreshPosts,
    required this.posts,
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
          const NavItem(icon: Icons.home_rounded, label: '홈', active: true),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            child: const NavItem(icon: Icons.search_rounded, label: '탐색'),
          ),
          AddButton(onPostCreated: onPostCreated),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlbumScreen()),
              );
            },
            child: const NavItem(
              icon: Icons.photo_library_rounded,
              label: '앨범',
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    posts: posts,
                    onRefreshPosts: onRefreshPosts,
                  ),
                ),
              );

              if (result == true) {
                onRefreshPosts();
              }
            },
            child: const NavItem(icon: Icons.pets_rounded, label: '프로필'),
          ),
        ],
      ),
    );
  }
}

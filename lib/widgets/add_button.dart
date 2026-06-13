import 'package:flutter/material.dart';

import '../models/post.dart';
import '../screens/create_post_screen.dart';

class AddButton extends StatelessWidget {
  final Function(Post, bool) onPostCreated;

  const AddButton({super.key, required this.onPostCreated});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreatePostScreen(onPostCreated: onPostCreated),
          ),
        );
      },
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          color: Color(0xFFFFE4D6),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 34,
          color: Color(0xFF4A2B22),
        ),
      ),
    );
  }
}

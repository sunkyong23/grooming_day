import 'package:flutter/material.dart';

import '../models/post.dart';

class ProfilePostGrid extends StatelessWidget {
  final List<Post> posts;

  const ProfilePostGrid({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final post = posts[index];

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(post.imageUrl, fit: BoxFit.cover),
        );
      },
    );
  }
}

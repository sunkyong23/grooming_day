import 'package:flutter/material.dart';

import '../models/post.dart';
import '../widgets/cat_post_card.dart';

class AlbumScreen extends StatelessWidget {
  final List<Post> posts;

  const AlbumScreen({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    final myPosts = posts.where((post) => !post.isAsset).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: const Text('나의 앨범'),
      ),
      body: myPosts.isEmpty
          ? const Center(child: Text('아직 앨범에 담긴 게시글이 없어요 🐾'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: myPosts.map((post) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: CatPostCard(
                    imagePath: post.imageUrl,
                    caption: post.caption,
                    likes: post.likes,
                    tagText: post.tags.map((tag) => '#$tag').join('   '),
                    isAsset: post.isAsset,
                    createdAt: post.createdAt,
                    catName: post.catName,
                    userId: post.userId,
                    isScrapped: post.isScrapped,
                    onScrapTap: () {},
                  ),
                );
              }).toList(),
            ),
    );
  }
}

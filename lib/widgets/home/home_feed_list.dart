import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/post.dart';
import '../cat_post_card.dart' hide ThreeDotLoading;
import '../common/three_dot_loading.dart';

class HomeFeedList extends StatelessWidget {
  final bool isLoadingPosts;
  final bool hasMorePosts;
  final List<Post> posts;
  final ScrollController feedScrollController;
  final AnimationController loadingController;
  final Map<String, int> commentCountOverrides;
  final void Function(Post post) onScrapTap;
  final void Function(Post post) onMoreTap;
  final void Function(String postId, int commentCount) onReviewChanged;
  final Set<String> scrappedPostIds;

  const HomeFeedList({
    super.key,
    required this.isLoadingPosts,
    required this.hasMorePosts,
    required this.posts,
    required this.feedScrollController,
    required this.loadingController,
    required this.commentCountOverrides,
    required this.onScrapTap,
    required this.onMoreTap,
    required this.onReviewChanged,
    required this.scrappedPostIds,
  });

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final filteredPosts = [...posts];

    if (isLoadingPosts && posts.isEmpty) {
      return Center(child: ThreeDotLoading(controller: loadingController));
    }

    return ListView.builder(
      controller: feedScrollController,
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 120),
      itemCount: filteredPosts.length + 1 + (hasMorePosts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const SizedBox(height: 24);
        }

        final postIndex = index - 1;

        if (postIndex >= filteredPosts.length) {
          if (!hasMorePosts) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: ThreeDotLoading(controller: loadingController),
            ),
          );
        }

        final post = filteredPosts[postIndex];

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: CatPostCard(
            imagePath: post.imageUrl,
            originalImagePath: post.imageUrl,
            caption: post.caption,
            catProfileImageUrl: post.catProfileImageUrl,
            isVirtualCat: post.isVirtualCat,
            scrapCount: post.scrapCount,
            tagText: post.tags.map((tag) => '#$tag').join('   '),
            createdAt: post.createdAt ?? DateTime.now(),
            catName: post.catName,
            userId: post.userId,
            commentCount: commentCountOverrides[post.id] ?? post.commentCount,
            postId: post.id,
            canWriteReview: post.ownerUid != currentUid,
            isScrapped: scrappedPostIds.contains(post.id),
            onReviewChanged: (commentCount) {
              onReviewChanged(post.id, commentCount);
            },
            onScrapTap: post.ownerUid == currentUid
                ? null
                : () {
                    onScrapTap(post);
                  },
            showMoreButton: true,
            onMoreTap: () {
              onMoreTap(post);
            },
          ),
        );
      },
    );
  }
}

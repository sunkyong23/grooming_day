import 'package:flutter/material.dart';

import '../../models/post.dart';

class AlbumGridView extends StatelessWidget {
  final List<Post> posts;
  final Set<String> selectedPostIds;
  final bool isSelectionMode;

  final void Function(Post post) onPostTap;
  final void Function(Post post) onPostLongPress;

  const AlbumGridView({
    super.key,
    required this.posts,
    required this.selectedPostIds,
    required this.isSelectionMode,
    required this.onPostTap,
    required this.onPostLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];

        final isSelected = selectedPostIds.contains(post.id);

        return GestureDetector(
          onTap: () => onPostTap(post),
          onLongPress: () => onPostLongPress(post),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    post.thumbnailUrl.isNotEmpty
                        ? post.thumbnailUrl
                        : post.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              if (isSelectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFF8A7A)
                          : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF8A7A),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

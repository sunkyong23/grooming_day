import 'package:flutter/material.dart';

class CatPostCard extends StatelessWidget {
  final String imagePath;
  final String caption;
  final int likes;
  final String tagText;
  final bool isAsset;
  final DateTime createdAt;
  final String catName;
  final String userId;
  final bool isScrapped;
  final VoidCallback onScrapTap;

  const CatPostCard({
    super.key,
    required this.imagePath,
    required this.caption,
    required this.likes,
    required this.tagText,
    required this.isAsset,
    required this.createdAt,
    required this.catName,
    required this.userId,
    required this.isScrapped,
    required this.onScrapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB58A7B).withValues(alpha: 0.13),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFFFFE2C6),
                  child: const Text('🐱', style: TextStyle(fontSize: 17)),
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        catName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3D241E),
                        ),
                      ),
                      Text(
                        '@$userId',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB08678),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 10, color: Color(0xFFC9AFA7)),
                ),
                SizedBox(width: 12),
                Icon(Icons.more_horiz, size: 21, color: Color(0xFF9A6B60)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierColor: Colors.black87,
                builder: (_) => GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: isAsset
                          ? Image.asset(imagePath)
                          : Image.network(imagePath),
                    ),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: isAsset
                  ? Image.asset(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    )
                  : Image.network(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        caption,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5A372F),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onScrapTap,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: isScrapped ? 1.15 : 1.0,
                        child: Icon(
                          isScrapped
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isScrapped
                              ? const Color(0xFFFF8A7A)
                              : const Color(0xFFC9B8AF),
                          size: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      '감상평  $likes',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFC0A39A),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      tagText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFE09086),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

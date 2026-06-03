class Post {
  final String id;
  final String imageUrl;
  final String caption;
  final int likes;
  final List<String> tags;
  final bool isAsset;
  final DateTime createdAt;
  final double aspectRatio;
  final String catName;
  final String userId;
  bool isScrapped;

  Post({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.tags,
    required this.createdAt,
    required this.aspectRatio,
    required this.catName,
    required this.userId,
    this.isAsset = true,
    this.isScrapped = false,
  });
}

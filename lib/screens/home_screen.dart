import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../models/post.dart';
import 'create_post_screen.dart';

import '../widgets/soft_divider.dart';
import '../widgets/cat_post_card.dart';
import '../widgets/tag_chip.dart';
import '../widgets/header.dart';
import '../widgets/bottom_nav_bar.dart';

import '../services/post_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> tags = const [
    '오늘의',
    '아깽이',
    '어르신',
    '장난꾸러기',
    '사랑스러운',
    '귀여워',
    '행복해',
    '일상',
    '평온한하루',
    '식빵굽기',
    '발라당',
    '심기불편',
    '사고뭉치',
    '정말못말려',
  ];

  String? selectedFeedTag = '오늘의';

  final List<Post> posts = [];
  final List<Post> myPosts = [];

  Future<void> loadMyScraps() async {
    // 스크랩 기능은 나중에 다시 연결
  }

  void addPost(Post post) {
    refreshPostLists();
  }

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await loadPostsFromFirestore();
    await loadMyPostsFromFirestore();
    await loadMyScraps();
  }

  Future<void> refreshPostLists() async {
    await loadPostsFromFirestore();
    await loadMyPostsFromFirestore();
    await loadMyScraps();
  }

  Future<void> loadPostsFromFirestore() async {
    final loadedPosts = await PostService.loadPosts();

    if (!mounted) return;

    setState(() {
      posts.clear();
      posts.addAll(loadedPosts);
    });
  }

  Future<void> loadPostsByTagFromFirestore(String tag) async {
    final loadedPosts = await PostService.loadPostsByTag(tag);

    if (!mounted) return;

    setState(() {
      posts.clear();
      posts.addAll(loadedPosts);
    });
  }

  Future<void> loadMyPostsFromFirestore() async {
    final loadedMyPosts = await PostService.loadMyPosts();

    if (!mounted) return;

    setState(() {
      myPosts.clear();
      myPosts.addAll(loadedMyPosts);
    });
  }

  Future<void> handleTagTap(String tag) async {
    if (!mounted) return;

    setState(() {
      if (tag == '오늘의') {
        selectedFeedTag = '오늘의';
      } else if (selectedFeedTag == tag) {
        selectedFeedTag = null;
      } else {
        selectedFeedTag = tag;
      }
    });

    try {
      if (tag == '오늘의' || selectedFeedTag == null) {
        await loadPostsFromFirestore();
      } else {
        await loadPostsByTagFromFirestore(tag);
      }
    } catch (e) {
      debugPrint('태그 피드 로딩 오류: $e');
    }
  }

  Future<void> toggleScrap(Post post) async {
    // 스크랩 기능은 나중에 다시 연결
  }

  Future<void> showPostMoreMenu(Post post) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFF7F1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('삭제'),
                  textColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    showDeletePostDialog(post);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showDeletePostDialog(Post post) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('게시글 삭제'),
          content: const Text('이 게시글을 삭제할까요? 삭제 후에는 되돌릴 수 없어요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await PostService.deletePost(post);

      await refreshPostLists();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('게시글이 삭제되었습니다.')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글 삭제 중 오류가 발생했습니다. 다시 시도해주세요.')),
      );
    }
  }

  Future<void> openCameraAndCreatePost() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;
    if (!mounted) return;

    final CropAspectRatio? selectedRatio =
        await showModalBottomSheet<CropAspectRatio>(
          context: context,
          backgroundColor: const Color(0xFFFFF7F1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (bottomSheetContext) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '사진 비율 선택',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 18),
                  ListTile(
                    leading: const Icon(Icons.crop_landscape),
                    title: const Text('가로 4:3'),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                        const CropAspectRatio(ratioX: 4, ratioY: 3),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.crop_portrait),
                    title: const Text('세로 4:5'),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                        const CropAspectRatio(ratioX: 4, ratioY: 5),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.crop_square),
                    title: const Text('정사각형 1:1'),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                        const CropAspectRatio(ratioX: 1, ratioY: 1),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );

    if (selectedRatio == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: selectedRatio,
    );

    if (croppedFile == null) return;
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          onPostCreated: addPost,
          initialImage: File(croppedFile.path),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = selectedFeedTag == '오늘의'
        ? ([...posts]..sort((a, b) => b.scrapCount.compareTo(a.scrapCount)))
        : [...posts];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      bottomNavigationBar: BottomNavBar(
        onPostCreated: addPost,
        onRefreshPosts: refreshPostLists,
        posts: myPosts,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Header(onCameraTap: openCameraAndCreatePost),
                  const SizedBox(height: 14),
                  const SoftDivider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: tags.map((tag) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () async {
                                    await handleTagTap(tag);
                                  },
                                  child: TagChip(
                                    key: ValueKey(tag),
                                    text: tag,
                                    isSelected: selectedFeedTag == tag,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: const Color(0xFFFFF7F1),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                            ),
                            builder: (bottomSheetContext) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  22,
                                  20,
                                  22,
                                  30,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '태그 전체보기',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF3D241E),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    GridView.count(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 2.5,
                                      children: tags.map((tag) {
                                        return GestureDetector(
                                          onTap: () async {
                                            await handleTagTap(tag);

                                            if (bottomSheetContext.mounted) {
                                              Navigator.pop(bottomSheetContext);
                                            }
                                          },
                                          child: TagChip(
                                            key: ValueKey('sheet_$tag'),
                                            text: tag,
                                            isSelected: selectedFeedTag == tag,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.grid_view_rounded,
                            size: 20,
                            color: Color(0xFF8A756C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 120),
                children: [
                  const SizedBox(height: 24),
                  ...filteredPosts.map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: CatPostCard(
                        imagePath: post.imageUrl,
                        caption: post.caption,
                        scrapCount: post.scrapCount,
                        tagText: post.tags.map((tag) => '#$tag').join('   '),
                        createdAt: post.createdAt ?? DateTime.now(),
                        catName: post.catName,
                        userId: post.userId,
                        isScrapped: false,
                        onScrapTap: () {
                          toggleScrap(post);
                        },
                        onMoreTap: () {
                          showPostMoreMenu(post);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

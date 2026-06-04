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
import '../services/cat_service.dart';

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

  Set<String> hiddenCatIds = {};

  Future<void> loadHiddenCats() async {
    final loadedHiddenCatIds = await CatService.loadHiddenCatIds();

    if (!mounted) return;

    setState(() {
      hiddenCatIds = loadedHiddenCatIds;
    });
  }

  final List<Post> posts = [
    Post(
      id: 'sample1',
      imageUrl: 'assets/images/cat1.png',
      caption: '크아아아앙!!!! 내 하품을 받아라 ♡',
      likes: 72,
      tags: ['귀여워', '일상', '평온한하루'],
      createdAt: DateTime.now(),
      aspectRatio: 4 / 5,
      catName: '가을이',
      userId: 'groomingday23',
      isAsset: true,
      catProfileId: '',
    ),
    Post(
      id: 'sample2',
      imageUrl: 'assets/images/cat2.png',
      caption: '노곤하당',
      likes: 25,
      tags: ['귀여워', '일상'],
      createdAt: DateTime.now(),
      aspectRatio: 4 / 5,
      catName: '모노',
      userId: 'monocat01',
      isAsset: true,
      catProfileId: '',
    ),
    Post(
      id: 'sample3',
      imageUrl: 'assets/images/cat1.png',
      caption: '오늘도 우다다다다다 🐱',
      likes: 99,
      tags: ['장난꾸러기', '귀여워'],
      createdAt: DateTime.now(),
      aspectRatio: 4 / 5,
      catName: '누렁',
      userId: 'cat22',
      isAsset: true,
      catProfileId: '',
    ),
  ];

  Future<void> loadMyScraps() async {
    final scrappedPostIds = await PostService.loadMyScrapIds();

    setState(() {
      for (final post in posts) {
        post.isScrapped = scrappedPostIds.contains(post.id);
      }
    });
  }

  void addPost(Post post) {
    setState(() {
      posts.insert(0, post);
    });
  }

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await loadPostsFromFirestore();
    await loadHiddenCats();
    await loadMyScraps();
  }

  Future<void> loadPostsFromFirestore() async {
    final loadedPosts = await PostService.loadPosts();

    setState(() {
      posts.removeWhere((post) => !post.isAsset);
      posts.insertAll(0, loadedPosts);
    });
  }

  Future<void> toggleScrap(Post post) async {
    final newValue = !post.isScrapped;

    setState(() {
      post.isScrapped = newValue;
    });

    await PostService.setScrap(post: post, isScrapped: newValue);
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
          builder: (_) {
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
                        context,
                        const CropAspectRatio(ratioX: 4, ratioY: 3),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.crop_portrait),
                    title: const Text('세로 4:5'),
                    onTap: () {
                      Navigator.pop(
                        context,
                        const CropAspectRatio(ratioX: 4, ratioY: 5),
                      );
                    },
                  ),

                  ListTile(
                    leading: const Icon(Icons.crop_square),
                    title: const Text('정사각형 1:1'),
                    onTap: () {
                      Navigator.pop(
                        context,
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
    final visiblePosts = posts.where((post) {
      return !hiddenCatIds.contains(post.catProfileId);
    }).toList();

    final filteredPosts = selectedFeedTag == null
        ? ([...visiblePosts]
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
        : selectedFeedTag == '오늘의'
        ? ([...visiblePosts]..sort((a, b) => b.likes.compareTo(a.likes)))
        : visiblePosts
              .where((post) => post.tags.contains(selectedFeedTag))
              .toList();
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      bottomNavigationBar: BottomNavBar(onPostCreated: addPost, posts: posts),
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
                                  onTap: () {
                                    setState(() {
                                      selectedFeedTag = selectedFeedTag == tag
                                          ? null
                                          : tag;
                                    });
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
                            builder: (_) {
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
                                          onTap: () {
                                            setState(() {
                                              selectedFeedTag =
                                                  selectedFeedTag == tag
                                                  ? null
                                                  : tag;
                                            });
                                            Navigator.pop(context);
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
                        likes: post.likes,
                        tagText: post.tags.map((tag) => '#$tag').join('   '),
                        isAsset: post.isAsset,
                        createdAt: post.createdAt,
                        catName: post.catName,
                        userId: post.userId,
                        isScrapped: post.isScrapped,
                        onScrapTap: () {
                          toggleScrap(post);
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

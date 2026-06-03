import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';

import '../models/post.dart';

import 'create_post_screen.dart';
import 'profile_screen.dart';

import '../widgets/soft_divider.dart';
import '../widgets/cat_post_card.dart';
import '../widgets/tag_chip.dart';
import '../widgets/header.dart';

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
    ),
  ];

  Future<void> loadMyScraps() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scraps')
        .get();

    final scrappedPostIds = snapshot.docs.map((doc) => doc.id).toSet();

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
    await loadMyScraps();
  }

  Future<void> loadPostsFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    final loadedPosts = snapshot.docs.map((doc) {
      final data = doc.data();

      return Post(
        id: data['id'] ?? doc.id,
        imageUrl: data['imageUrl'] ?? '',
        caption: data['caption'] ?? '',
        likes: data['likes'] ?? 0,
        tags: List<String>.from(data['tags'] ?? []),
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        aspectRatio: (data['aspectRatio'] ?? 4 / 5).toDouble(),
        catName: data['catName'] ?? '가을이',
        userId: data['userId'] ?? '',
        isAsset: false,
      );
    }).toList();

    setState(() {
      posts.removeWhere((post) => !post.isAsset);
      posts.insertAll(0, loadedPosts);
    });
  }

  Future<void> toggleScrap(Post post) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final scrapRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('scraps')
        .doc(post.id);

    final newValue = !post.isScrapped;

    setState(() {
      post.isScrapped = newValue;
    });

    if (newValue) {
      await scrapRef.set({
        'postId': post.id,
        'imageUrl': post.imageUrl,
        'caption': post.caption,
        'catName': post.catName,
        'userId': post.userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await scrapRef.delete();
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
    final filteredPosts = selectedFeedTag == null
        ? ([...posts]..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
        : selectedFeedTag == '오늘의'
        ? ([...posts]..sort((a, b) => b.likes.compareTo(a.likes)))
        : posts.where((post) => post.tags.contains(selectedFeedTag)).toList();
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

class BottomNavBar extends StatelessWidget {
  final Function(Post) onPostCreated;
  final List<Post> posts;

  const BottomNavBar({
    super.key,
    required this.onPostCreated,
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
          const NavItem(icon: Icons.search_rounded, label: '탐색'),
          AddButton(onPostCreated: onPostCreated),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AlbumScreen(posts: posts)),
              );
            },
            child: const NavItem(
              icon: Icons.photo_library_rounded,
              label: '앨범',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(posts: posts)),
              );
            },
            child: const NavItem(icon: Icons.pets_rounded, label: '프로필'),
          ),
        ],
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  final Function(Post) onPostCreated;

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
          color: Color(0xFFFFDFAF),
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

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF8A4F45) : const Color(0xFF6A443B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w900 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

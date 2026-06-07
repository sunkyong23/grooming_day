import 'package:flutter/material.dart';

import '../models/cat_profile.dart';
import '../services/cat_service.dart';

import '../models/post.dart';
import '../services/post_service.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'edit_cat_profile_screen.dart';

import '../services/favorite_cat_service.dart';

class CatProfileDetailScreen extends StatefulWidget {
  final CatProfile cat;

  const CatProfileDetailScreen({super.key, required this.cat});

  @override
  State<CatProfileDetailScreen> createState() => _CatProfileDetailScreenState();
}

class _CatProfileDetailScreenState extends State<CatProfileDetailScreen> {
  List<Post> catPosts = [];
  bool isFavoriteCat = false;
  bool isFavoriteLoading = false;

  @override
  void initState() {
    super.initState();
    loadCatPosts();
    loadFavoriteState();
  }

  Future<void> toggleFavoriteCat() async {
    if (isFavoriteLoading) return;

    setState(() {
      isFavoriteLoading = true;
    });

    try {
      if (isFavoriteCat) {
        await FavoriteCatService.removeFavoriteCat(widget.cat.id);
      } else {
        await FavoriteCatService.addFavoriteCat(
          catProfileId: widget.cat.id,
          ownerUid: widget.cat.ownerUid,
          catName: widget.cat.name,
          catProfileImageUrl: widget.cat.profileImageUrl,
        );
      }

      if (!mounted) return;

      setState(() {
        isFavoriteCat = !isFavoriteCat;
      });
    } finally {
      if (mounted) {
        setState(() {
          isFavoriteLoading = false;
        });
      }
    }
  }

  Future<void> loadFavoriteState() async {
    final result = await FavoriteCatService.isFavoriteCat(widget.cat.id);

    if (!mounted) return;

    setState(() {
      isFavoriteCat = result;
    });
  }

  Future<void> loadCatPosts() async {
    final posts = await PostService.loadPostsByCatProfile(widget.cat.id);

    if (!mounted) return;

    setState(() {
      catPosts = posts;
    });
  }

  String getCatAge(DateTime? birthDate) {
    if (birthDate == null) {
      return '나이 정보 없음';
    }

    final now = DateTime.now();

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;

    if (now.day < birthDate.day) {
      months -= 1;
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    if (years <= 0) {
      return '$months개월';
    }

    if (months == 0) {
      return '$years살';
    }

    return '$years살 $months개월';
  }

  String getBirthDateText(DateTime? birthDate) {
    if (birthDate == null) {
      return '생일 정보 없음';
    }

    return '${birthDate.year}.${birthDate.month.toString().padLeft(2, '0')}.${birthDate.day.toString().padLeft(2, '0')}';
  }

  Future<bool> _showHideConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('고양이 프로필 숨기기'),
          content: const Text('이 고양이 프로필을 숨길까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('숨기기'),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  Future<bool> _showDeleteConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('고양이 프로필 삭제'),
          content: const Text('정말 이 고양이 프로필을 삭제할까요?\n삭제된 프로필은 목록에서 보이지 않아요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final isOwner =
        FirebaseAuth.instance.currentUser?.uid == widget.cat.ownerUid;

    final canFavorite = !isOwner;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: Text(widget.cat.name),
        actions: [
          if (canFavorite)
            GestureDetector(
              onTap: toggleFavoriteCat,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Image.asset(
                  isFavoriteCat
                      ? 'assets/icons/paw_fill.png'
                      : 'assets/icons/paw_outline.png',
                  width: 26,
                  height: 26,
                ),
              ),
            ),

          if (isOwner)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz),
              onSelected: (value) async {
                final navigator = Navigator.of(context);

                if (value == 'edit') {
                  final result = await navigator.push(
                    MaterialPageRoute(
                      builder: (_) => EditCatProfileScreen(cat: widget.cat),
                    ),
                  );

                  if (result == true) {
                    if (!mounted) return;

                    navigator.pop(true);
                  }
                }

                if (value == 'hide') {
                  final confirm = await _showHideConfirmDialog();

                  if (!confirm) return;

                  await CatService.hideCatProfile(widget.cat.id);

                  if (!mounted) return;

                  navigator.pop(true);
                }

                if (value == 'unhide') {
                  await CatService.unhideCatProfile(widget.cat.id);

                  if (!mounted) return;

                  navigator.pop(true);
                }

                if (value == 'delete') {
                  final confirm = await _showDeleteConfirmDialog();

                  if (!confirm) return;

                  await CatService.deleteCatProfile(widget.cat.id);

                  if (!mounted) return;

                  // delete 안
                  navigator.pop(true);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('프로필 수정')),
                PopupMenuItem(
                  value: widget.cat.isHidden ? 'unhide' : 'hide',
                  child: Text(widget.cat.isHidden ? '숨김 해제' : '숨기기'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('프로필 삭제', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFFFE2C6),
                backgroundImage:
                    !widget.cat.isVirtualCat &&
                        widget.cat.profileImageUrl.isNotEmpty
                    ? NetworkImage(widget.cat.profileImageUrl)
                    : null,
                child: widget.cat.isVirtualCat
                    ? Padding(
                        padding: const EdgeInsets.all(18),
                        child: Image.asset(
                          'assets/icons/today_cat.png',
                          fit: BoxFit.contain,
                        ),
                      )
                    : widget.cat.profileImageUrl.isEmpty
                    ? const Icon(Icons.pets, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                widget.cat.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 8),

            if (!widget.cat.isVirtualCat) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  getCatAge(widget.cat.birthDate),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8C6A5F),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            if (widget.cat.introduction.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  widget.cat.introduction,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF4A2B22),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            if (widget.cat.personalityTags.isNotEmpty) ...[
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.cat.personalityTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE9DE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF5A88B)),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8C6A5F),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (!widget.cat.isVirtualCat) ...[
              _infoTile(
                '품종',
                widget.cat.breed.isEmpty ? '미입력' : widget.cat.breed,
              ),
              _infoTile('성별', widget.cat.gender),
              _infoTile('생일', getBirthDateText(widget.cat.birthDate)),
            ],

            const SizedBox(height: 30),

            const Text(
              '앨범',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),

            const SizedBox(height: 12),

            catPosts.isEmpty
                ? Container(
                    height: 160,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text('게시글이 없습니다 🐾'),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: catPosts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                    itemBuilder: (context, index) {
                      final post = catPosts[index];

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(post.imageUrl, fit: BoxFit.cover),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(
              '$title : ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      ),
    );
  }
}

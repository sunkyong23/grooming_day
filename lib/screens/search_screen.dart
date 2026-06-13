import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cat_profile.dart';
import '../services/cat_service.dart';
import '../services/user_service.dart';
import 'cat_profile_detail_screen.dart';
import 'user_profile_screen.dart';
import '../services/block_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  Timer? _debounce;
  int selectedTabIndex = 0;
  bool isLoading = false;

  List<CatProfile> searchedCats = [];
  List<Map<String, dynamic>> searchedUsers = [];

  @override
  void deactivate() {
    FocusManager.instance.primaryFocus?.unfocus();
    super.deactivate();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchAll();
    });
  }

  Future<void> searchAll() async {
    final keyword = searchController.text.trim();

    if (keyword.isEmpty) {
      setState(() {
        searchedCats = [];
        searchedUsers = [];
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final blockedUids = await BlockService.loadBlockedUserUids();

    if (selectedTabIndex == 0) {
      final results = await CatService.searchCatsByName(keyword);

      final visibleCats = results.where((cat) {
        return !blockedUids.contains(cat.ownerUid);
      }).toList();

      if (!mounted) return;

      setState(() {
        searchedCats = visibleCats;
        isLoading = false;
      });
    } else {
      final results = await UserService.searchUsers(keyword);

      final visibleUsers = results.where((user) {
        final uid = user['uid'] as String? ?? '';
        return !blockedUids.contains(uid);
      }).toList();

      if (!mounted) return;

      setState(() {
        searchedUsers = visibleUsers;
        isLoading = false;
      });
    }
  }

  void changeTab(int index) {
    setState(() {
      selectedTabIndex = index;
      searchedCats = [];
      searchedUsers = [];
    });

    searchAll();
  }

  @override
  Widget build(BuildContext context) {
    final isCatTab = selectedTabIndex == 0;
    final hasResult = isCatTab
        ? searchedCats.isNotEmpty
        : searchedUsers.isNotEmpty;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFFF7F1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFF7F1),
            title: const Text('검색'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: isCatTab ? '고양이 이름을 검색해 보세요' : '집사 아이디를 검색해 보세요',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchedCats = [];
                          searchedUsers = [];
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _SearchTabButton(
                        title: '고양이',
                        isSelected: selectedTabIndex == 0,
                        onTap: () => changeTab(0),
                      ),
                      _SearchTabButton(
                        title: '집사',
                        isSelected: selectedTabIndex == 1,
                        onTap: () => changeTab(1),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CircularProgressIndicator(),
                  )
                else if (!hasResult)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Text(
                      '검색 결과가 없어요',
                      style: TextStyle(
                        color: Color(0xFF8C6A5F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (isCatTab)
                  Expanded(child: _buildCatList())
                else
                  Expanded(child: _buildUserList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatList() {
    return ListView.builder(
      itemCount: searchedCats.length,
      itemBuilder: (context, index) {
        final cat = searchedCats[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CatProfileDetailScreen(cat: cat),
              ),
            );
          },
          child: _ResultCard(
            imageUrl: cat.isVirtualCat ? '' : cat.profileImageUrl,
            fallbackIcon: cat.isVirtualCat ? null : Icons.pets,
            fallbackAsset: cat.isVirtualCat
                ? 'assets/icons/today_cat.png'
                : null,
            title: cat.name,
            subtitle: cat.ownerUserId.isEmpty
                ? cat.introduction
                : '@${cat.ownerUserId}',
          ),
        );
      },
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: searchedUsers.length,
      itemBuilder: (context, index) {
        final user = searchedUsers[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(
                  ownerUid: user['uid'] ?? '',
                  userId: user['userId'] ?? '',
                  bio: user['bio'] ?? '',
                  profileImageUrl: user['profileImageUrl'] ?? '',
                ),
              ),
            );
          },
          child: _UserResultCard(user: user),
        );
      },
    );
  }
}

class _SearchTabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SearchTabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFBE5D8) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF3D241E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String imageUrl;
  final IconData? fallbackIcon;
  final String? fallbackAsset;
  final String title;
  final String subtitle;

  const _ResultCard({
    required this.imageUrl,
    this.fallbackIcon,
    this.fallbackAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFFE2C6),
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            child: imageUrl.isEmpty
                ? fallbackAsset != null
                      ? Image.asset(fallbackAsset!, width: 28, height: 28)
                      : Icon(fallbackIcon ?? Icons.pets)
                : null,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3D241E),
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8C6A5F),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB08678)),
        ],
      ),
    );
  }
}

class _UserResultCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const _UserResultCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final uid = user['uid'] ?? '';
    final userId = user['userId'] ?? '';
    final bio = user['bio'] ?? '';
    final profileImageUrl = user['profileImageUrl'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFFFE2C6),
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl.isEmpty
                    ? const Icon(Icons.person_rounded)
                    : null,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$userId',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3D241E),
                      ),
                    ),
                    if (bio.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8C6A5F),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          FutureBuilder<List<CatProfile>>(
            future: CatService.loadPublicCatsByOwnerUid(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 36,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              final cats = snapshot.data ?? [];

              if (cats.isEmpty) {
                return const Text(
                  '공개된 고양이 프로필이 없어요 🐾',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB08678),
                    fontWeight: FontWeight.w600,
                  ),
                );
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cats.map((cat) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CatProfileDetailScreen(cat: cat),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E7),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFFD7B8)),
                      ),
                      child: Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4A2B22),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

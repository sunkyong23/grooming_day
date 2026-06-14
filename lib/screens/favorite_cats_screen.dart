import 'package:flutter/material.dart';

import '../models/favorite_cat.dart';
import '../services/favorite_cat_service.dart';

import '../services/cat_service.dart';
import 'cat_profile_detail_screen.dart';

class FavoriteCatsScreen extends StatefulWidget {
  const FavoriteCatsScreen({super.key});

  @override
  State<FavoriteCatsScreen> createState() => _FavoriteCatsScreenState();
}

class _FavoriteCatsScreenState extends State<FavoriteCatsScreen> {
  bool isLoading = true;

  List<FavoriteCat> favoriteCats = [];

  @override
  void initState() {
    super.initState();
    loadFavoriteCats();
  }

  Future<void> loadFavoriteCats() async {
    final loadedCats = await FavoriteCatService.loadFavoriteCats();

    if (!mounted) return;

    setState(() {
      favoriteCats = loadedCats;
      isLoading = false;
    });
  }

  Future<void> openCatDetail(FavoriteCat cat) async {
    final catProfile = await CatService.loadCatProfileById(cat.catProfileId);

    if (catProfile == null) return;
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatProfileDetailScreen(cat: catProfile),
      ),
    );

    if (!mounted) return;

    await loadFavoriteCats();
  }

  Widget buildCatAvatar(FavoriteCat cat) {
    final isVirtualCat =
        cat.catName == '랜선집사' && cat.catProfileImageUrl.isEmpty;

    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFFFFE2C6),
      backgroundImage: !isVirtualCat && cat.catProfileImageUrl.isNotEmpty
          ? NetworkImage(cat.catProfileImageUrl)
          : null,
      child: isVirtualCat
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                'assets/icons/today_cat.png',
                fit: BoxFit.contain,
              ),
            )
          : cat.catProfileImageUrl.isEmpty
          ? const Icon(Icons.pets_rounded, color: Color(0xFF8A756C), size: 24)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
        title: const Text(
          '꾹꾹 고양이',
          style: TextStyle(
            color: Color(0xFF5C4033),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteCats.isEmpty
          ? const Center(
              child: Text(
                '아직 꾹꾹한 고양이가 없어요 🐾',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF8C6A5F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 40),
              itemCount: favoriteCats.length,
              itemBuilder: (context, index) {
                final cat = favoriteCats[index];

                return GestureDetector(
                  onTap: () async {
                    await openCatDetail(cat);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      children: [
                        buildCatAvatar(cat),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.catName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1F1A24),
                                ),
                              ),
                              if (cat.ownerUserId.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '@${cat.ownerUserId}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFB08678),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFB08678),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

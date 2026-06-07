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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: const Text('꾹꾹 고양이'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteCats.isEmpty
          ? const Center(
              child: Text('아직 꾹꾹한 고양이가 없어요 🐾', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteCats.length,
              itemBuilder: (context, index) {
                final cat = favoriteCats[index];

                return GestureDetector(
                  onTap: () async {
                    final catProfile = await CatService.loadCatProfileById(
                      cat.catProfileId,
                    );

                    if (catProfile == null) return;

                    if (!context.mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CatProfileDetailScreen(cat: catProfile),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFFFE2C6),
                          backgroundImage: cat.catProfileImageUrl.isNotEmpty
                              ? NetworkImage(cat.catProfileImageUrl)
                              : null,
                          child: cat.catProfileImageUrl.isEmpty
                              ? const Icon(Icons.pets)
                              : null,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.catName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (cat.ownerUserId.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    '@${cat.ownerUserId}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFB08678),
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
              },
            ),
    );
  }
}

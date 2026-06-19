import 'package:flutter/material.dart';

import '../models/post.dart';
import '../widgets/bottom_nav_bar.dart';
import 'album_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int currentIndex = 0;

  final GlobalKey<HomeScreenState> homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<AlbumScreenState> albumKey = GlobalKey<AlbumScreenState>();
  final GlobalKey<ProfileScreenState> profileKey =
      GlobalKey<ProfileScreenState>();

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      HomeScreen(key: homeKey, onPostCreatedFromHome: handlePostCreated),
      const SearchScreen(),
      AlbumScreen(key: albumKey),
      ProfileScreen(
        key: profileKey,
        posts: const [],
        onRefreshPosts: refreshHomePosts,
      ),
    ];
  }

  void refreshAlbum() {
    albumKey.currentState?.loadMyPosts();
    albumKey.currentState?.loadCatProfiles();

    if (albumKey.currentState?.selectedAlbumTab == 1) {
      albumKey.currentState?.loadMyScrappedPosts();
    }
  }

  void refreshProfile() {
    profileKey.currentState?.loadUser();
    profileKey.currentState?.loadCatProfiles();
    profileKey.currentState?.loadMyPostCount();
  }

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });

    if (index == 0) {
      homeKey.currentState?.refreshPostLists();
    }

    if (index == 2) {
      refreshAlbum();
    }

    if (index == 3) {
      refreshProfile();
    }
  }

  void handlePostCreated(Post post, bool isAlbumOnlyPost) {
    homeKey.currentState?.addPost(post);
    albumKey.currentState?.loadMyPosts();
    albumKey.currentState?.loadCatProfiles();
    profileKey.currentState?.loadMyPostCount();
    profileKey.currentState?.loadCatProfiles();

    if (isAlbumOnlyPost) {
      setState(() {
        currentIndex = 2;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        refreshAlbum();
        refreshProfile();
      });

      return;
    }

    setState(() {
      currentIndex = 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeKey.currentState?.scrollFeedToTop();
      refreshProfile();
    });
  }

  void refreshHomePosts() {
    homeKey.currentState?.refreshPostLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,
        onTap: changeTab,
        onPostCreated: handlePostCreated,
      ),
    );
  }
}

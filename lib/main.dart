import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Post {
  final String imagePath;
  final String caption;
  final int likes;
  final List<String> tags;
  final bool isAsset;
  final DateTime createdAt;

  Post({
    required this.imagePath,
    required this.caption,
    required this.likes,
    required this.tags,
    required this.createdAt,
    this.isAsset = true,
  });
}

void main() {
  runApp(const GroomingDayApp());
}

class GroomingDayApp extends StatelessWidget {
  const GroomingDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset('assets/images/splash.png', fit: BoxFit.cover),
      ),
    );
  }
}

class CreatePostScreen extends StatefulWidget {
  final Function(Post) onPostCreated;

  const CreatePostScreen({super.key, required this.onPostCreated});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  final TextEditingController captionController = TextEditingController();

  final List<String> tags = [
    '아깽이',
    '어른신',
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

  final List<String> selectedTags = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFF7F1),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: const Text('게시글 작성'),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              GestureDetector(
                onTap: () async {
                  print('사진 영역 클릭됨!');
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (image != null) {
                    setState(() {
                      selectedImage = File(image.path);
                    });
                  }
                },

                child: Container(
                  height: 220,
                  width: double.infinity,

                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: selectedImage == null
                      ? const Center(
                          child: Icon(Icons.add_photo_alternate, size: 60),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            selectedImage!,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: captionController,

                maxLines: 3,

                decoration: InputDecoration(
                  hintText: '우리 냥이를 소개해 주세요 🐱',

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text('태그 선택 (최대 3개)'),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,

                children: tags.map((tag) {
                  final selected = selectedTags.contains(tag);

                  return FilterChip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? const Color(0xFF4A2B22)
                            : const Color(0xFF8C6A5F),
                      ),
                    ),

                    selected: selected,

                    showCheckmark: false,

                    selectedColor: const Color(0xFFFFE9DE),

                    backgroundColor: Colors.white,

                    side: BorderSide(
                      color: selected
                          ? const Color(0xFFF5A88B)
                          : const Color(0xFFE8E1DB),
                    ),

                    onSelected: (_) {
                      setState(() {
                        if (selected) {
                          selectedTags.remove(tag);
                        } else {
                          if (selectedTags.length < 3) {
                            selectedTags.add(tag);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {
                    if (selectedImage == null) return;

                    final newPost = Post(
                      imagePath: selectedImage!.path,
                      caption: captionController.text,
                      likes: 0,
                      tags: selectedTags,
                      createdAt: DateTime.now(),
                      isAsset: false,
                    );

                    widget.onPostCreated(newPost);

                    Navigator.pop(context);
                  },

                  child: const Text('게시하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> tags = const [
    '오늘의 😺',
    '아깽이',
    '어른신',
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

  final List<Post> posts = [
    Post(
      imagePath: 'assets/images/cat1.png',
      caption: '크아아아앙!!!! 내 하품을 받아라 ♡',
      likes: 72,
      tags: ['귀여워', '일상', '평온한하루'],
      createdAt: DateTime.now(),
    ),
    Post(
      imagePath: 'assets/images/cat2.png',
      caption: '노곤하당',
      likes: 25,
      tags: ['귀여워', '일상'],
      createdAt: DateTime.now(),
    ),
    Post(
      imagePath: 'assets/images/cat1.png',
      caption: '오늘도 우다다다다다 🐱',
      likes: 99,
      tags: ['장난꾸러기', '귀여워'],
      createdAt: DateTime.now(),
    ),
  ];

  void addPost(Post post) {
    setState(() {
      posts.insert(0, post);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      bottomNavigationBar: BottomNavBar(onPostCreated: addPost, posts: posts),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 120),
          children: [
            const Header(),
            const SizedBox(height: 22),
            const SoftDivider(),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: tags.map((tag) => TagChip(text: tag)).toList(),
            ),
            const SizedBox(height: 24),

            ...posts.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: CatPostCard(
                  imagePath: post.imagePath,
                  caption: post.caption,
                  likes: post.likes,
                  tagText: post.tags.map((tag) => '#$tag').join('   '),
                  isAsset: post.isAsset,
                  createdAt: post.createdAt,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '그루밍데이',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF351A14),
                ),
              ),
              SizedBox(height: 6),
              Text(
                '오늘도 너와 함께하는 하루',
                style: TextStyle(fontSize: 16, color: Color(0xFF5E3D35)),
              ),
            ],
          ),
        ),
        HeaderIcon(icon: Icons.notifications_none_rounded),
        SizedBox(width: 10),
        HeaderIcon(icon: Icons.photo_camera_outlined),
      ],
    );
  }
}

class HeaderIcon extends StatelessWidget {
  final IconData icon;

  const HeaderIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEACB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFF7A4A42), size: 23),
    );
  }
}

class SoftDivider extends StatelessWidget {
  const SoftDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0D9),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Center(
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFFFFC48E),
          size: 24,
        ),
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  final String text;

  const TagChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final bool selected = text.contains('오늘의');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFE4DE) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? const Color(0xFFFFA09A) : const Color(0xFFF5E5DD),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? const Color(0xFFE57373) : const Color(0xFF5D3B34),
        ),
      ),
    );
  }
}

class CatPostCard extends StatelessWidget {
  final String imagePath;
  final String caption;
  final int likes;
  final String tagText;
  final bool isAsset;
  final DateTime createdAt;

  const CatPostCard({
    super.key,
    required this.imagePath,
    required this.caption,
    required this.likes,
    required this.tagText,
    required this.isAsset,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB58A7B).withOpacity(0.13),
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
                  backgroundColor: Color(0xFFFFE2C6),
                  child: Text('🐱', style: TextStyle(fontSize: 17)),
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '가을이',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3D241E),
                        ),
                      ),
                      Text(
                        'groomingday',
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
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: isAsset
                ? Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(imagePath),
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
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
                    const Icon(
                      Icons.bookmark_border_rounded,
                      color: Color(0xFF9A6B60),
                      size: 23,
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
                    imagePath: post.imagePath,
                    caption: post.caption,
                    likes: post.likes,
                    tagText: post.tags.map((tag) => '#$tag').join('   '),
                    isAsset: post.isAsset,
                    createdAt: post.createdAt,
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
            color: Colors.black.withOpacity(0.08),
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
          const NavItem(icon: Icons.pets_rounded, label: '프로필'),
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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 50, 28, 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              const Icon(
                Icons.pets_rounded,
                size: 72,
                color: Color(0xFF5A2C24),
              ),

              const SizedBox(height: 18),

              const Text(
                '그루밍데이',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF351A14),
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'grooming day',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                  color: Color(0xFF9B746A),
                ),
              ),

              const Spacer(flex: 2),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB58A7B).withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const LoginInput(
                      icon: Icons.person_outline_rounded,
                      label: '아이디',
                      hint: '아이디를 입력해주세요',
                    ),

                    const SizedBox(height: 24),

                    const LoginInput(
                      icon: Icons.lock_outline_rounded,
                      label: '비밀번호',
                      hint: '비밀번호를 입력해주세요',
                      obscure: true,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE89078),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '집사 입장하기',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE89078),
                          side: const BorderSide(
                            color: Color(0xFFE89078),
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '처음 오셨나요? 집사 등록하기',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              TextButton(
                onPressed: () {},
                child: const Text(
                  '비밀번호를 잊으셨나요?',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6A352C),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginInput extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final bool obscure;

  const LoginInput({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF6A352C), size: 26),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF351A14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFD0B8AE)),
            filled: true,
            fillColor: const Color(0xFFFFF4EC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            suffixIcon: obscure
                ? const Icon(
                    Icons.visibility_off_outlined,
                    color: Color(0xFF9B746A),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF2D6C8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF2D6C8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE89078),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 44, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF5A2C24),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                '처음 뵙는 집사님!\n정말 반가워요 :)',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                  color: Color(0xFF351A14),
                ),
              ),

              const SizedBox(height: 54),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB58A7B).withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    LoginInput(
                      icon: Icons.person_outline_rounded,
                      label: '아이디',
                      hint: '사용할 아이디를 입력해주세요',
                    ),
                    SizedBox(height: 22),
                    LoginInput(
                      icon: Icons.lock_outline_rounded,
                      label: '비밀번호',
                      hint: '비밀번호를 입력해주세요',
                      obscure: true,
                    ),
                    SizedBox(height: 22),
                    LoginInput(
                      icon: Icons.lock_outline_rounded,
                      label: '비밀번호 확인',
                      hint: '비밀번호를 다시 입력해주세요',
                      obscure: true,
                    ),
                    SizedBox(height: 22),
                    LoginInput(
                      icon: Icons.email_outlined,
                      label: '이메일',
                      hint: '이메일을 입력해주세요',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE89078),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '계정 생성하기',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '이미 계정이 있으신가요?  로그인',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFFE89078),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

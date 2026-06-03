import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/settings_screen.dart';
import 'models/post.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const GroomingDayApp());
}

class GroomingDayApp extends StatelessWidget {
  const GroomingDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class CreatePostScreen extends StatefulWidget {
  final Function(Post) onPostCreated;
  final File? initialImage;

  const CreatePostScreen({
    super.key,
    required this.onPostCreated,
    this.initialImage,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

Future<File?> compressImage(File file) async {
  final dir = await getTemporaryDirectory();

  final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 60,
    minWidth: 1000,
    minHeight: 1000,
  );

  if (compressedFile == null) {
    return null;
  }

  return File(compressedFile.path);
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  final TextEditingController captionController = TextEditingController();
  double selectedAspectRatio = 4 / 5;
  final List<String> tags = [
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

  final List<String> selectedTags = [];
  String currentUserId = 'groomingday23';
  Future<File?> pickAndCropImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return null;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 5),
    );

    if (croppedFile == null) return null;

    return File(croppedFile.path);
  }

  @override
  void initState() {
    super.initState();

    loadCurrentUserId();

    if (widget.initialImage != null) {
      selectedImage = widget.initialImage;
    }
  }

  Future<void> loadCurrentUserId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      setState(() {
        currentUserId = doc.data()?['userId'] ?? 'groomingday23';
      });
    }
  }

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

                  if (image == null) return;

                  final ratio = await showModalBottomSheet<double>(
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const ListTile(
                              title: Text(
                                '사진 비율 선택',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListTile(
                              title: const Text('가로형 4:3'),
                              onTap: () => Navigator.pop(context, 4 / 3),
                            ),
                            ListTile(
                              title: const Text('세로형 4:5'),
                              onTap: () => Navigator.pop(context, 4 / 5),
                            ),
                            ListTile(
                              title: const Text('정사각형 1:1'),
                              onTap: () => Navigator.pop(context, 1.0),
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  if (ratio == null) return;

                  selectedAspectRatio = ratio;

                  final croppedFile = await ImageCropper().cropImage(
                    sourcePath: image.path,
                    aspectRatio: CropAspectRatio(
                      ratioX: ratio == 4 / 3
                          ? 4
                          : ratio == 1.0
                          ? 1
                          : 4,
                      ratioY: ratio == 4 / 3
                          ? 3
                          : ratio == 1.0
                          ? 1
                          : 5,
                    ),
                  );

                  if (croppedFile != null) {
                    setState(() {
                      selectedImage = File(croppedFile.path);
                    });
                  }
                },

                child: Container(
                  constraints: BoxConstraints(
                    minHeight: selectedImage == null ? 220 : 0,
                    maxHeight: selectedImage == null ? 260 : double.infinity,
                  ),
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
                  onPressed: () async {
                    if (selectedImage == null) return;

                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    final postId = FirebaseFirestore.instance
                        .collection('posts')
                        .doc()
                        .id;

                    final storageRef = FirebaseStorage.instance
                        .ref()
                        .child('posts')
                        .child(user.uid)
                        .child('$postId.jpg');

                    final compressedImage = await compressImage(selectedImage!);

                    final uploadFile = compressedImage ?? selectedImage!;

                    await storageRef.putFile(uploadFile);

                    final imageUrl = await storageRef.getDownloadURL();

                    final newPost = Post(
                      id: postId,
                      imageUrl: imageUrl,
                      caption: captionController.text,
                      likes: 0,
                      tags: selectedTags,
                      createdAt: DateTime.now(),
                      aspectRatio: selectedAspectRatio,
                      catName: '가을이',
                      userId: currentUserId,
                      isAsset: false,
                    );

                    await FirebaseFirestore.instance
                        .collection('posts')
                        .doc(postId)
                        .set({
                          'id': postId,
                          'imageUrl': imageUrl,
                          'caption': captionController.text,
                          'likes': 0,
                          'tags': selectedTags,
                          'createdAt': Timestamp.now(),
                          'aspectRatio': selectedAspectRatio,
                          'catName': '가을이',
                          'userId': currentUserId,
                          'ownerUid': user.uid,
                        });

                    widget.onPostCreated(newPost);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
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

class ProfileScreen extends StatefulWidget {
  final List<Post> posts;

  const ProfileScreen({super.key, required this.posts});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userId = '로딩중...';

  String profileImageUrl = '';
  File? selectedProfileImage;

  String bio = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> uploadProfileImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        IOSUiSettings(
          title: '프로필 사진 자르기',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile == null) return;

    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      croppedFile.path,
      targetPath,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );

    if (compressedFile == null) return;

    final file = File(compressedFile.path);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(uid)
        .child('profile.jpg');

    await ref.putFile(file);

    final imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'profileImageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      selectedProfileImage = file;
      profileImageUrl = imageUrl;
    });
  }

  Future<void> editBio() async {
    final bioController = TextEditingController(text: bio);

    final newBio = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('소개글 수정'),
          content: TextField(
            controller: bioController,
            maxLength: 50,
            decoration: const InputDecoration(hintText: '한줄 소개를 입력해주세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, bioController.text.trim());
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );

    if (newBio == null) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'bio': newBio,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      bio = newBio;
    });
  }

  Future<void> loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      setState(() {
        userId = doc['userId'];
        profileImageUrl = doc['profileImageUrl'] ?? '';
        bio = doc['bio'] ?? '';
        email = doc['email'] ?? '';
      });
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('계정 탈퇴'),
          content: const Text('정말 탈퇴하시겠습니까?\n모든 정보가 삭제됩니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showReauthDialog();
              },
              child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showReauthDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('본인 확인'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: '비밀번호를 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final user = FirebaseAuth.instance.currentUser;

                if (user == null) return;

                final credential = EmailAuthProvider.credential(
                  email: user.email!,
                  password: passwordController.text.trim(),
                );

                try {
                  await user.reauthenticateWithCredential(credential);

                  await _deleteAccount();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('비밀번호가 올바르지 않습니다.')),
                  );
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final uid = user.uid;

      final postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('ownerUid', isEqualTo: uid)
          .get();

      for (final doc in postsSnapshot.docs) {
        final postId = doc.id;

        try {
          await FirebaseStorage.instance.ref('posts/$uid/$postId.jpg').delete();
        } catch (e) {
          print('게시글 이미지 삭제 실패: $e');
        }

        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .delete();
      }

      try {
        await FirebaseStorage.instance.ref('users/$uid/profile.jpg').delete();
      } catch (e) {
        print('프로필 이미지 삭제 실패: $e');
      }

      final scrapsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('scraps')
          .get();

      for (final doc in scrapsSnapshot.docs) {
        await doc.reference.delete();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      await user.delete();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('계정 탈퇴 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final myPosts = widget.posts.where((post) => !post.isAsset).toList();
    final scrappedPosts = widget.posts
        .where((post) => post.isScrapped)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: const Text('프로필'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: uploadProfileImage,
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFFFFE2C6),
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? NetworkImage(profileImageUrl)
                      : null,
                  child: profileImageUrl.isEmpty
                      ? const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF8A756C),
                          size: 30,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '@$userId',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                currentUserId: userId,
                                currentBio: bio,
                              ),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              userId = result['userId'];
                              bio = result['bio'];
                            });
                          }
                        },
                        child: const Text('편집'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    bio.isEmpty ? '소개글을 작성해주세요 🐾' : bio,
                    style: const TextStyle(
                      color: Color(0xFF7A6A5B),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '게시글 ${myPosts.length}개',
                    style: const TextStyle(color: Color(0xFFB08678)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 여기부터 기존 가을이 카드 Container 이어서 두면 됨
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '가을이',

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('오늘도 귀여움으로 하루를 채우는 고양이 🐾'),

          const SizedBox(height: 24),
          const Text(
            '내 게시글',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: myPosts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final post = myPosts[index];

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: post.isAsset
                    ? Image.asset(post.imageUrl, fit: BoxFit.cover)
                    : Image.network(post.imageUrl, fit: BoxFit.cover),
              );
            },
          ),

          const SizedBox(height: 28),

          const Text(
            '스크랩',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 12),

          scrappedPosts.isEmpty
              ? const Text(
                  '아직 스크랩한 게시글이 없어요 🐾',

                  style: TextStyle(color: Color(0xFFB08678)),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: scrappedPosts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    final post = scrappedPosts[index];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: post.isAsset
                          ? Image.asset(post.imageUrl, fit: BoxFit.cover)
                          : Image.network(post.imageUrl, fit: BoxFit.cover),
                    );
                  },
                ),
          const SizedBox(height: 40),

          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    email: email,
                    onDeleteAccountTap: _showDeleteAccountDialog,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: const Row(
                children: [
                  Icon(Icons.settings_rounded, color: Color(0xFF8A756C)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '설정',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3D241E),
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Color(0xFFB08678)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final String currentUserId;
  final String currentBio;

  const EditProfileScreen({
    super.key,
    required this.currentUserId,
    required this.currentBio,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController userIdController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    userIdController = TextEditingController(text: widget.currentUserId);
    bioController = TextEditingController(text: widget.currentBio);
  }

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final newUserId = userIdController.text.trim();
    final newBio = bioController.text.trim();

    final regex = RegExp(r'^[a-zA-Z0-9]+$');

    if (!regex.hasMatch(newUserId)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디는 영어와 숫자만 사용할 수 있습니다.')));
      return;
    }

    final duplicateCheck = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: newUserId)
        .limit(1)
        .get();

    if (duplicateCheck.docs.isNotEmpty && duplicateCheck.docs.first.id != uid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미 사용 중인 아이디입니다.')));
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'userId': newUserId,
      'bio': newBio,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    Navigator.pop(context, {'userId': newUserId, 'bio': newBio});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
        title: const Text('프로필 편집'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: '아이디',
                hintText: '아이디를 입력해주세요',
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: bioController,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: '소개글',
                hintText: '한줄 소개를 입력해주세요',
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: saveProfile,
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdateDetailScreen extends StatelessWidget {
  final String version;
  final String title;
  final String content;

  const UpdateDetailScreen({
    super.key,
    required this.version,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        title: const Text(
          '업데이트 내역',
          style: TextStyle(color: Color(0xFF5C4033)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '🚀 $version',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB08678),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3D241E),
              height: 1.35,
            ),
          ),

          const SizedBox(height: 22),

          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6A554B),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

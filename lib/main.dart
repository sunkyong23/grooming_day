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

class Post {
  final String id;
  final String imageUrl;
  final String caption;
  final int likes;
  final List<String> tags;
  final bool isAsset;
  final DateTime createdAt;
  final double aspectRatio;
  final String catName;
  final String userId;
  bool isScrapped;

  Post({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.tags,
    required this.createdAt,
    required this.aspectRatio,
    required this.catName,
    required this.userId,
    this.isAsset = true,
    this.isScrapped = false,
  });
}

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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    } on FirebaseAuthException catch (e) {
      String message = '로그인에 실패했습니다.';

      if (e.code == 'invalid-credential' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password') {
        message = '이메일 또는 비밀번호가 올바르지 않습니다.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 80, 30, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 70),

                const Center(
                  child: Text(
                    '그루밍데이',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                      color: Color(0xFF3D241E),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    '오늘도 너와 함께하는 하루',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7A5B50),
                    ),
                  ),
                ),

                const SizedBox(height: 52),

                _LoginInput(
                  controller: emailController,
                  hintText: '이메일',
                  icon: Icons.mail_outline_rounded,
                ),

                const SizedBox(height: 14),

                _LoginInput(
                  controller: passwordController,
                  hintText: '비밀번호',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                ),

                const SizedBox(height: 28),

                Center(
                  child: SizedBox(
                    width: 220,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD9C9),
                        foregroundColor: const Color(0xFF5A3A31),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        isLoading ? '입장 중...' : '집사 입장하기',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '비밀번호를 잊으셨나요?',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: TextButton(
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8A756C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        title: const Text('비밀번호 재설정'),
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Text(
              '가입한 이메일을 입력해주세요.\n비밀번호 재설정 메일을 보내드릴게요.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: '이메일'),
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: emailController.text.trim(),
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('비밀번호 재설정 메일을 발송했습니다.')),
                        );
                      } on FirebaseAuthException catch (e) {
                        String message = '메일 발송에 실패했습니다.';

                        if (e.code == 'invalid-email') {
                          message = '올바른 이메일 형식이 아닙니다.';
                        }

                        if (!mounted) return;

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(message)));
                      } finally {
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
              child: Text(isLoading ? '발송 중...' : '재설정 메일 보내기'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;

  const _LoginInput({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0DDD2), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF9B7A70)),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFB79B92),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userIdController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isTermsAgreed = false;
  bool isPrivacyAgreed = false;

  bool isLoading = false;

  Future<void> register() async {
    if (isLoading) return;
    if (!isTermsAgreed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이용약관에 동의해주세요.')));
      return;
    }

    if (!isPrivacyAgreed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('개인정보 처리방침에 동의해주세요.')));
      return;
    }

    final userId = userIdController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (userId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디를 입력해주세요.')));
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일을 입력해주세요.')));
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호를 입력해주세요.')));
      return;
    }

    if (confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호 확인을 입력해주세요.')));
      return;
    }

    final regex = RegExp(r'^[a-zA-Z0-9]+$');

    if (!regex.hasMatch(userId)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('아이디는 영어와 숫자만 사용할 수 있습니다.')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final duplicateCheck = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (duplicateCheck.docs.isNotEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이미 사용 중인 아이디입니다.')));

        return;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'userId': userId,
        'profileImageUrl': '',
        'bio': '',
        'accountType': 'catOwner',
        'isDeleted': false,
        'isSuspended': false,
        'termsAgreedAt': FieldValue.serverTimestamp(),
        'privacyAgreedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = '회원가입 중 오류가 발생했습니다.';

      if (e.code == 'invalid-email') {
        message = '이메일 형식이 올바르지 않습니다.';
      } else if (e.code == 'email-already-in-use') {
        message = '이미 사용 중인 이메일입니다.';
      } else if (e.code == 'weak-password') {
        message = '비밀번호는 6자 이상 입력해주세요.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        title: const Text('집사 등록하기'),
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              TextField(
                controller: userIdController,
                decoration: const InputDecoration(hintText: '아이디'),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: '이메일'),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: '비밀번호 (6자 이상)'),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: '비밀번호 확인'),
              ),

              Row(
                children: [
                  Checkbox(
                    value: isTermsAgreed,
                    onChanged: (value) {
                      setState(() {
                        isTermsAgreed = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '이용약관에 동의합니다. (필수)',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  Checkbox(
                    value: isPrivacyAgreed,
                    onChanged: (value) {
                      setState(() {
                        isPrivacyAgreed = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrivacyPolicyScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '개인정보 처리방침에 동의합니다. (필수)',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: isLoading ? null : register,
                child: Text(isLoading ? '가입 중...' : '집사 등록 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이용약관')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text('''
그루밍데이 이용약관

제1조 (목적)
본 서비스는 반려묘 사진 및 기록을 공유하는 서비스를 제공합니다.

제2조 (회원의 의무)
타인의 권리를 침해하는 게시물을 등록할 수 없습니다.

제3조 (서비스 이용)
회원은 관련 법령을 준수해야 합니다.
            '''),
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('개인정보 처리방침')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text('''
개인정보 처리방침

그루밍데이는 회원가입 시 이메일, 사용자 아이디 정보를 저장합니다.

수집된 정보는 서비스 제공 목적 외에는 사용하지 않습니다.

회원 탈퇴 시 관련 정보는 삭제됩니다.
            '''),
        ),
      ),
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
        MaterialPageRoute(builder: (_) => const AuthGate()),
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
                  Container(height: 1, color: const Color(0xFFE9DDD4)),

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

class Header extends StatelessWidget {
  final VoidCallback onCameraTap;

  const Header({super.key, required this.onCameraTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '그루밍데이',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF351A14),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '오늘도 너와 함께하는 하루',
                style: TextStyle(fontSize: 16, color: Color(0xFF5E3D35)),
              ),
            ],
          ),
        ),
        HeaderIcon(icon: Icons.notifications_none_rounded),
        SizedBox(width: 10),
        HeaderIcon(icon: Icons.photo_camera_outlined, onTap: onCameraTap),
      ],
    );
  }
}

class HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const HeaderIcon({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFFFDCD1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: const Color(0xFF7A4A42), size: 23),
      ),
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
  final bool isSelected;

  const TagChip({super.key, required this.text, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF0E7) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: -0.3,
              color: isSelected
                  ? const Color(0xFF3D241E)
                  : const Color(0xFF6A554B),
            ),
          ),

          if (text == '오늘의') ...[
            const SizedBox(width: 4),

            Image.asset('assets/icons/today_cat.png', width: 16, height: 16),
          ],
        ],
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
  final String catName;
  final String userId;
  final bool isScrapped;
  final VoidCallback onScrapTap;

  const CatPostCard({
    super.key,
    required this.imagePath,
    required this.caption,
    required this.likes,
    required this.tagText,
    required this.isAsset,
    required this.createdAt,
    required this.catName,
    required this.userId,
    required this.isScrapped,
    required this.onScrapTap,
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
                  backgroundColor: const Color(0xFFFFE2C6),
                  child: const Text('🐱', style: TextStyle(fontSize: 17)),
                ),
                SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        catName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3D241E),
                        ),
                      ),
                      Text(
                        '@${userId}',
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
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierColor: Colors.black87,
                builder: (_) => GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: isAsset
                          ? Image.asset(imagePath)
                          : Image.network(imagePath),
                    ),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: isAsset
                  ? Image.asset(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    )
                  : Image.network(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
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
                    GestureDetector(
                      onTap: onScrapTap,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: isScrapped ? 1.15 : 1.0,
                        child: Icon(
                          isScrapped
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isScrapped
                              ? const Color(0xFFFF8A7A)
                              : const Color(0xFFC9B8AF),
                          size: 23,
                        ),
                      ),
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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요.')));
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('새 비밀번호는 6자 이상이어야 합니다.')));
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('새 비밀번호가 일치하지 않습니다.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: '로그인 정보를 찾을 수 없습니다.',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호가 변경되었습니다.')));

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String message = '비밀번호 변경에 실패했습니다.';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = '현재 비밀번호가 올바르지 않습니다.';
      } else if (e.code == 'weak-password') {
        message = '새 비밀번호가 너무 약합니다.';
      } else if (e.code == 'requires-recent-login') {
        message = '보안을 위해 다시 로그인 후 시도해주세요.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        title: const Text(
          '비밀번호 변경',
          style: TextStyle(color: Color(0xFF5C4033)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '현재 비밀번호'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '새 비밀번호'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '새 비밀번호 확인'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _changePassword,
                child: Text(isLoading ? '변경 중...' : '비밀번호 변경하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final String email;
  final VoidCallback onDeleteAccountTap;

  const SettingsScreen({
    super.key,
    required this.email,
    required this.onDeleteAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        title: const Text('설정', style: TextStyle(color: Color(0xFF5C4033))),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.campaign_rounded,
                color: Color(0xFF8A756C),
              ),
              title: const Text(
                '공지사항',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3D241E),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB08678),
              ),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const NoticeScreen()));
              },
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.rocket_launch_rounded,
                color: Color(0xFF8A756C),
              ),
              title: const Text(
                '업데이트 내역',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3D241E),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB08678),
              ),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const UpdateScreen()));
              },
            ),

            const SizedBox(height: 20),

            const SizedBox(height: 32),

            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
              child: const Text('개인정보 처리방침'),
            ),

            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const TermsScreen()));
              },
              child: const Text('이용약관'),
            ),

            const SizedBox(height: 20),
            Text(
              '이메일\n$email',
              style: const TextStyle(fontSize: 14, color: Color(0xFF8A756C)),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                );
              },
              child: const Text('비밀번호 변경'),
            ),

            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text('로그아웃'),
            ),

            TextButton(
              onPressed: onDeleteAccountTap,
              child: const Text('계정 탈퇴', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F2),
        elevation: 0,
        title: const Text('공지사항', style: TextStyle(color: Color(0xFF5C4033))),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .where('isVisible', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                '등록된 공지사항이 없어요 🐾',
                style: TextStyle(color: Color(0xFFB08678)),
              ),
            );
          }

          final notices = snapshot.data!.docs;

          notices.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aPinned = aData['isPinned'] == true;
            final bPinned = bData['isPinned'] == true;

            if (aPinned != bPinned) {
              return aPinned ? -1 : 1;
            }

            final aCreatedAt = aData['createdAt'] as Timestamp?;
            final bCreatedAt = bData['createdAt'] as Timestamp?;

            if (aCreatedAt == null || bCreatedAt == null) return 0;

            return bCreatedAt.compareTo(aCreatedAt);
          });

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: notices.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 28, color: Color(0xFFE8DCD4)),
            itemBuilder: (context, index) {
              final notice = notices[index];
              final data = notice.data() as Map<String, dynamic>;

              final title = data['title'] ?? '제목 없음';
              final content = data['content'] ?? '';
              final isPinned = data['isPinned'] ?? false;
              final createdAt = data['createdAt'] as Timestamp?;
              final dateText = createdAt == null
                  ? ''
                  : '${createdAt.toDate().year}.${createdAt.toDate().month.toString().padLeft(2, '0')}.${createdAt.toDate().day.toString().padLeft(2, '0')}';

              return ListTile(
                contentPadding: EdgeInsets.zero,

                title: Text(
                  isPinned ? '📌 $title' : title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3D241E),
                  ),
                ),

                subtitle: dateText.isEmpty
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          dateText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB08678),
                          ),
                        ),
                      ),

                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB08678),
                ),

                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          NoticeDetailScreen(title: title, content: content),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class NoticeDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const NoticeDetailScreen({
    super.key,
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
        title: const Text('공지사항', style: TextStyle(color: Color(0xFF5C4033))),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 21,
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

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('updates')
            .where('isVisible', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final updates = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: updates.length,
            itemBuilder: (context, index) {
              final data = updates[index].data() as Map<String, dynamic>;

              final version = data['version'] ?? '';

              final title = data['title'] ?? '';

              final content = data['content'] ?? '';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '🚀 $version',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3D241E),
                  ),
                ),
                subtitle: Text(title),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => UpdateDetailScreen(
                        version: version,
                        title: title,
                        content: content,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
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

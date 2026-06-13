import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/cat_profile.dart';
import '../models/post.dart';
import '../services/image_service.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../services/cat_service.dart';

import 'cat_profile_type_select_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostScreen extends StatefulWidget {
  final Function(Post, bool) onPostCreated;
  final File? initialImage;

  const CreatePostScreen({
    super.key,
    required this.onPostCreated,
    this.initialImage,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  final TextEditingController captionController = TextEditingController();

  double selectedAspectRatio = 4 / 5;
  String currentUserId = 'groomingday23';

  List<CatProfile> catProfiles = [];
  CatProfile? selectedCatProfile;
  bool isLoadingCats = true;
  bool isSubmitting = false;

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

  @override
  void initState() {
    super.initState();

    loadCurrentUserId();
    loadMyCatProfiles();

    if (widget.initialImage != null) {
      selectedImage = widget.initialImage;
    }
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  Future<void> loadCurrentUserId() async {
    final loadedUserId = await UserService.loadCurrentUserId();

    if (!mounted) return;

    setState(() {
      currentUserId = loadedUserId;
    });
  }

  Future<void> loadMyCatProfiles() async {
    try {
      final loadedCats = await CatService.loadMyCatProfiles();
      final visibleCats = loadedCats.where((cat) => !cat.isHidden).toList();

      if (!mounted) return;

      setState(() {
        catProfiles = visibleCats;
        selectedCatProfile = visibleCats.isNotEmpty ? visibleCats.first : null;
        isLoadingCats = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        catProfiles = [];
        selectedCatProfile = null;
        isLoadingCats = false;
      });
    }
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    if (!mounted) return;

    final ratio = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: const Color(0xFFFFF8F2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '사진 비율 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5C4033),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ratioTile(bottomSheetContext, '가로형 4:3', 4 / 3),
                _ratioTile(bottomSheetContext, '세로형 4:5', 4 / 5),
                _ratioTile(bottomSheetContext, '정사각형 1:1', 1.0),
              ],
            ),
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

    if (croppedFile == null) return;

    setState(() {
      selectedImage = File(croppedFile.path);
    });
  }

  Widget _ratioTile(BuildContext context, String title, double ratio) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5C4033),
        ),
      ),
      onTap: () => Navigator.pop(context, ratio),
    );
  }

  Future<void> showCatSelectBottomSheet() async {
    final cat = await showModalBottomSheet<CatProfile>(
      context: context,
      backgroundColor: const Color(0xFFFFF8F2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '고양이 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5C4033),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...catProfiles.map((cat) {
                  final isSelected = selectedCatProfile?.id == cat.id;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFFFE2C6),
                      backgroundImage:
                          !cat.isVirtualCat && cat.profileImageUrl.isNotEmpty
                          ? NetworkImage(cat.profileImageUrl)
                          : null,
                      child: cat.isVirtualCat
                          ? Padding(
                              padding: const EdgeInsets.all(6),
                              child: Image.asset(
                                'assets/icons/today_cat.png',
                                fit: BoxFit.contain,
                              ),
                            )
                          : cat.profileImageUrl.isEmpty
                          ? const Icon(
                              Icons.pets,
                              size: 20,
                              color: Color(0xFF8A5A44),
                            )
                          : null,
                    ),
                    title: Text(
                      cat.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5C4033),
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFFE8A58A),
                          )
                        : null,
                    onTap: () => Navigator.pop(bottomSheetContext, cat),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (cat == null) return;

    setState(() {
      selectedCatProfile = cat;
    });
  }

  Future<void> submitPost() async {
    FocusScope.of(context).unfocus();

    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    final isSuspended = userDoc.data()?['isSuspended'] == true;

    if (isSuspended) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('정지된 계정은 게시글을 작성할 수 없어요.')));

      setState(() {
        isSubmitting = false;
      });

      return;
    }

    try {
      if (selectedImage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('게시할 사진을 선택해주세요.')));
        return;
      }

      if (selectedCatProfile == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('고양이 프로필을 먼저 등록해주세요.')));
        return;
      }

      final isAlbumOnlyPost = selectedTags.isEmpty;

      final compressedImage = await ImageService.compressImage(selectedImage!);
      final uploadFile = compressedImage ?? selectedImage!;

      final newPost = await PostService.createPost(
        imageFile: uploadFile,
        caption: captionController.text,
        tags: selectedTags,
        aspectRatio: selectedAspectRatio,
        catName: selectedCatProfile!.name,
        catProfileId: selectedCatProfile!.id,
        userId: currentUserId,
        catProfileImageUrl: selectedCatProfile!.profileImageUrl,
        isVirtualCat: selectedCatProfile!.isVirtualCat,
      );

      if (newPost == null) return;

      widget.onPostCreated(newPost, isAlbumOnlyPost);

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      setState(() {
        selectedTags.remove(tag);
      });
      return;
    }

    if (selectedTags.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('태그는 최대 3개까지 선택할 수 있어요 🐾'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      selectedTags.add(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '게시글 작성',
          style: TextStyle(
            color: Color(0xFF1F1A24),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: pickImageFromGallery,
                child: Container(
                  height: selectedImage == null ? 200 : null,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEFE6),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: selectedImage == null
                      ? const Center(
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 58,
                            color: Color(0xFF8A5A44),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.file(
                            selectedImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              if (isLoadingCats)
                const Center(child: CircularProgressIndicator())
              else if (catProfiles.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '게시글을 작성하려면 먼저 고양이 프로필을 등록해주세요.',
                        style: TextStyle(
                          color: Color(0xFF8C6A5F),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFE2C6),
                            foregroundColor: const Color(0xFF5C4033),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CatProfileTypeSelectScreen(),
                              ),
                            );

                            loadMyCatProfiles();
                          },
                          child: const Text('고양이 프로필 등록하기'),
                        ),
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: showCatSelectBottomSheet,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF3E3DA)),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '고양이',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB08678),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            selectedCatProfile?.name ?? '고양이 선택',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3D241E),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF8A756C),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 18),

              TextField(
                controller: captionController,
                cursorColor: const Color(0xFF8A5A44),
                maxLines: 4,
                style: const TextStyle(color: Color(0xFF5A372F), fontSize: 16),
                decoration: InputDecoration(
                  hintText: '소중한 순간을 남겨보아요 🐱',
                  hintStyle: const TextStyle(color: Color(0xFFC9B8AE)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFF3E3DA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFF3E3DA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFFE8A58A),
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                '태그 선택',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3D241E),
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: tags.map((tag) {
                  final selected = selectedTags.contains(tag);

                  return FilterChip(
                    visualDensity: const VisualDensity(
                      horizontal: -2,
                      vertical: -3,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: Text(
                      tag,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: selected
                            ? const Color(0xFF4A2B22)
                            : const Color(0xFFB69788),
                      ),
                    ),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: const Color(0xFFFBE5D8),
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (_) {
                      toggleTag(tag);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD8CC),
                    foregroundColor: const Color(0xFF5C4033),
                    disabledBackgroundColor: const Color(0xFFF3E8E1),
                    disabledForegroundColor: const Color(0xFFB8A79E),
                    elevation: 0,
                    shadowColor: const Color(0x22000000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          submitPost();
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          '게시하기',
                          style: TextStyle(
                            fontSize: 16,
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

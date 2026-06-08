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
      builder: (bottomSheetContext) {
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
                onTap: () => Navigator.pop(bottomSheetContext, 4 / 3),
              ),
              ListTile(
                title: const Text('세로형 4:5'),
                onTap: () => Navigator.pop(bottomSheetContext, 4 / 5),
              ),
              ListTile(
                title: const Text('정사각형 1:1'),
                onTap: () => Navigator.pop(bottomSheetContext, 1.0),
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

    if (croppedFile == null) return;

    setState(() {
      selectedImage = File(croppedFile.path);
    });
  }

  Future<void> submitPost() async {
    FocusScope.of(context).unfocus();

    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

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
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        if (selectedTags.length < 3) {
          selectedTags.add(tag);
        }
      }
    });
  }

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
                onTap: pickImageFromGallery,
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

              if (isLoadingCats)
                const Center(child: CircularProgressIndicator())
              else if (catProfiles.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                DropdownButtonFormField<CatProfile>(
                  initialValue: selectedCatProfile,
                  decoration: InputDecoration(
                    labelText: '고양이 선택',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  items: catProfiles.map((cat) {
                    return DropdownMenuItem<CatProfile>(
                      value: cat,
                      child: Text(cat.name),
                    );
                  }).toList(),
                  onChanged: (cat) {
                    setState(() {
                      selectedCatProfile = cat;
                    });
                  },
                ),

              const SizedBox(height: 20),

              TextField(
                controller: captionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '소중한 순간을 남겨보아요 🐱',
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
                      toggleTag(tag);
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                      : const Text('게시하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

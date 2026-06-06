import 'package:flutter/material.dart';

import '../models/post.dart';

import '../services/post_service.dart';

import '../models/cat_profile.dart';
import '../services/cat_service.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late final TextEditingController captionController;
  late List<String> selectedTags;

  List<CatProfile> catProfiles = [];
  CatProfile? selectedCatProfile;
  File? selectedImage;
  double selectedAspectRatio = 0.8;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    captionController = TextEditingController(text: widget.post.caption);
    selectedTags = List<String>.from(widget.post.tags);
    loadCatProfiles();
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  Future<void> loadCatProfiles() async {
    final loadedCats = await CatService.loadMyCatProfiles();

    if (!mounted) return;

    CatProfile? currentCat;

    for (final cat in loadedCats) {
      if (cat.id == widget.post.catProfileId) {
        currentCat = cat;
        break;
      }
    }

    setState(() {
      catProfiles = loadedCats;
      selectedCatProfile = currentCat;
    });
  }

  Future<void> pickNewImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    if (!mounted) return;

    final CropAspectRatio? selectedRatio =
        await showModalBottomSheet<CropAspectRatio>(
          context: context,
          backgroundColor: const Color(0xFFFFF7F1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (bottomSheetContext) {
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
                        bottomSheetContext,
                        const CropAspectRatio(ratioX: 4, ratioY: 3),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.crop_portrait),
                    title: const Text('세로 4:5'),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
                        const CropAspectRatio(ratioX: 4, ratioY: 5),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.crop_square),
                    title: const Text('정사각형 1:1'),
                    onTap: () {
                      Navigator.pop(
                        bottomSheetContext,
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
    if (!mounted) return;

    setState(() {
      selectedImage = File(croppedFile.path);

      if (selectedRatio.ratioX == 4 && selectedRatio.ratioY == 3) {
        selectedAspectRatio = 4 / 3;
      } else if (selectedRatio.ratioX == 1 && selectedRatio.ratioY == 1) {
        selectedAspectRatio = 1;
      } else {
        selectedAspectRatio = 4 / 5;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
        title: const Text(
          '게시글 수정',
          style: TextStyle(
            color: Color(0xFF3D241E),
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          TextButton(
            onPressed: isSaving
                ? null
                : () async {
                    setState(() {
                      isSaving = true;
                    });

                    try {
                      await PostService.updatePost(
                        post: widget.post,
                        caption: captionController.text.trim(),
                        tags: selectedTags,
                        catProfileId: selectedCatProfile!.id,
                        catName: selectedCatProfile!.name,
                        catProfileImageUrl: selectedCatProfile!.profileImageUrl,
                        isVirtualCat: selectedCatProfile!.isVirtualCat,
                        newImageFile: selectedImage,
                        newAspectRatio: selectedAspectRatio,
                      );

                      if (!context.mounted) return;
                      Navigator.pop(
                        context,
                        selectedTags.isEmpty ? 'album' : 'home',
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          isSaving = false;
                        });
                      }
                    }
                  },
            child: Text(
              isSaving ? '저장 중...' : '저장',
              style: const TextStyle(
                color: Color(0xFF8A5A44),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Color(0xFF3D241E)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: selectedImage == null
                  ? Image.network(
                      widget.post.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    )
                  : Image.file(
                      selectedImage!,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: pickNewImage,
                icon: const Icon(Icons.image_outlined),
                label: const Text('사진 변경'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8A5A44),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              '고양이',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3D241E),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CatProfile>(
                  value: selectedCatProfile,
                  isExpanded: true,
                  hint: const Text('고양이를 선택해주세요'),
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
              ),
            ),

            const SizedBox(height: 22),
            const Text(
              '내용',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3D241E),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: captionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '게시글 내용을 입력해주세요.',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              '태그',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3D241E),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                final isSelected = selectedTags.contains(tag);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedTags.remove(tag);
                      } else {
                        if (selectedTags.length >= 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('태그는 최대 3개까지 선택할 수 있어요.'),
                            ),
                          );
                          return;
                        }

                        selectedTags.add(tag);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFD7B8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF8A5A44)
                            : const Color(0xFF666666),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

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
}

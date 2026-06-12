import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../services/rainbow_service.dart';

class CreateRainbowLetterScreen extends StatefulWidget {
  const CreateRainbowLetterScreen({super.key});

  @override
  State<CreateRainbowLetterScreen> createState() =>
      _CreateRainbowLetterScreenState();
}

class _CreateRainbowLetterScreenState extends State<CreateRainbowLetterScreen> {
  final titleController = TextEditingController();
  final catNameController = TextEditingController();
  final contentController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? selectedImage;
  bool isSubmitting = false;
  bool isPublic = true;

  @override
  void dispose() {
    titleController.dispose();
    catNameController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    if (!mounted) return;

    final CropAspectRatio? selectedRatio =
        await showModalBottomSheet<CropAspectRatio>(
          context: context,
          backgroundColor: const Color(0xFF0B113A),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (bottomSheetContext) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '사진 비율 선택',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(
                        Icons.crop_landscape_rounded,
                        color: Color(0xFFFFDCA8),
                      ),
                      title: const Text(
                        '가로형 4:3',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(
                          bottomSheetContext,
                          const CropAspectRatio(ratioX: 4, ratioY: 3),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.crop_portrait_rounded,
                        color: Color(0xFFFFDCA8),
                      ),
                      title: const Text(
                        '세로형 4:5',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(
                          bottomSheetContext,
                          const CropAspectRatio(ratioX: 4, ratioY: 5),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.crop_square_rounded,
                        color: Color(0xFFFFDCA8),
                      ),
                      title: const Text(
                        '정사각형 1:1',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(
                          bottomSheetContext,
                          const CropAspectRatio(ratioX: 1, ratioY: 1),
                        );
                      },
                    ),
                  ],
                ),
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

    setState(() {
      selectedImage = File(croppedFile.path);
    });
  }

  Future<void> submitLetter() async {
    if (isSubmitting) return;

    if (titleController.text.trim().isEmpty ||
        catNameController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목, 아이 이름, 내용을 모두 입력해주세요.')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await RainbowService().createLetter(
        title: titleController.text.trim(),
        catName: catNameController.text.trim(),
        content: contentController.text.trim(),
        imageFile: selectedImage,
        isPublic: isPublic,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isPublic ? '무지개별에 편지를 남겼어요.' : '내 편지함에 편지를 보관했어요.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('무지개별 편지 저장 오류: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('편지를 저장하지 못했어요: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Widget buildImagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: selectedImage == null
            ? const Row(
                children: [
                  Icon(Icons.photo_outlined, color: Color(0xFFFFDCA8)),
                  SizedBox(width: 10),
                  Text(
                    '추억 사진 선택하기 (선택)',
                    style: TextStyle(
                      color: Color(0xFFFFDCA8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      selectedImage!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '사진을 다시 선택하려면 이미지를 눌러주세요.',
                    style: TextStyle(color: Color(0xFFB8BDD8), fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildVisibilitySelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '공개 범위',
            style: TextStyle(
              color: Color(0xFFFFDCA8),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _VisibilityOption(
            isSelected: isPublic,
            title: '무지개별 전체 공개',
            subtitle: '다른 집사들도 이 편지를 볼 수 있어요.',
            onTap: () {
              setState(() {
                isPublic = true;
              });
            },
          ),
          const SizedBox(height: 10),
          _VisibilityOption(
            isSelected: !isPublic,
            title: '내 편지함에만 보관',
            subtitle: '나만 볼 수 있는 편지로 저장돼요.',
            onTap: () {
              setState(() {
                isPublic = false;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B113A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B113A),
        foregroundColor: Colors.white,
        title: const Text('추억 남기기'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          _InputField(
            controller: titleController,
            label: '제목',
            hintText: '가을이에게',
          ),
          const SizedBox(height: 16),
          _InputField(
            controller: catNameController,
            label: '고양이 이름',
            hintText: '가을이',
          ),
          const SizedBox(height: 16),
          _InputField(
            controller: contentController,
            label: '내용',
            hintText: '오늘도 네 생각이 났어.',
            maxLines: 12,
          ),
          const SizedBox(height: 16),
          buildImagePicker(),
          const SizedBox(height: 16),
          buildVisibilitySelector(),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: isSubmitting ? null : submitLetter,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFDCA8),
              foregroundColor: const Color(0xFF3D241E),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '무지개별에 남기기',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.isSelected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFDCA8).withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFDCA8)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: const Color(0xFFFFDCA8),
              size: 21,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFB8BDD8),
                      fontSize: 12,
                      height: 1.3,
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: const TextStyle(color: Color(0xFFFFDCA8)),
        hintStyle: const TextStyle(color: Color(0xFF8F95B8)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

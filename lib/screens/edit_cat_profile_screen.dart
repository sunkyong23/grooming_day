import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/cat_profile.dart';
import '../services/cat_service.dart';
import '../utils/cat_validator.dart';

class EditCatProfileScreen extends StatefulWidget {
  final CatProfile cat;

  const EditCatProfileScreen({super.key, required this.cat});

  @override
  State<EditCatProfileScreen> createState() => _EditCatProfileScreenState();
}

class _EditCatProfileScreenState extends State<EditCatProfileScreen> {
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final introductionController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  File? selectedImage;
  DateTime? selectedBirthDate;
  bool isSubmitting = false;

  final List<String> personalityOptions = [
    '애교쟁이',
    '상냥함',
    '장난꾸러기',
    '온순함',
    '먹보',
    '겁쟁이',
    '호기심왕',
    '집사바라기',
    '개냥이',
    '도도함',
    '순둥이',
    '활발함',
    '잠꾸러기',
    '수다쟁이',
    '대장',
    '게으른',
    '까칠함',
    '느긋함',
    '차분함',
    '똥꼬발랄',
    '심드렁',
    '마이웨이',
  ];

  late List<String> selectedPersonalities;

  @override
  void initState() {
    super.initState();

    nameController.text = widget.cat.name;
    breedController.text = widget.cat.breed;
    introductionController.text = widget.cat.introduction;
    selectedBirthDate = widget.cat.birthDate;
    selectedPersonalities = List<String>.from(widget.cat.personalityTags);
  }

  @override
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    introductionController.dispose();
    super.dispose();
  }

  String get birthDateText {
    if (selectedBirthDate == null) {
      return '생일을 선택해주세요';
    }

    return '${selectedBirthDate!.year}.${selectedBirthDate!.month.toString().padLeft(2, '0')}.${selectedBirthDate!.day.toString().padLeft(2, '0')}';
  }

  Future<void> pickCatImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );

    if (croppedFile == null) return;

    setState(() {
      selectedImage = File(croppedFile.path);
    });
  }

  Future<void> pickBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedBirthDate = pickedDate;
    });
  }

  Future<void> submitEditCatProfile() async {
    final name = nameController.text.trim();
    final breed = breedController.text.trim();
    final introduction = introductionController.text.trim();

    if (isSubmitting) return;

    setState(() {
      isSubmitting = true;
    });

    if (name.isEmpty) {
      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('고양이 이름을 입력해주세요.')));
      return;
    }

    if (!CatValidator.isValidKoreanName(name) && !widget.cat.isVirtualCat) {
      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('고양이 이름은 한글만 입력해주세요.')));
      return;
    }

    if (!widget.cat.isVirtualCat && selectedPersonalities.isEmpty) {
      setState(() {
        isSubmitting = false;
      });

      if (!widget.cat.isVirtualCat && selectedBirthDate == null) {
        setState(() {
          isSubmitting = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('고양이 생일을 선택해주세요.')));
        return;
      }

      if (!widget.cat.isVirtualCat && breed.isEmpty) {
        setState(() {
          isSubmitting = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('품종을 입력해주세요.')));
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('성격을 1개 이상 선택해주세요.')));
      return;
    }

    await CatService.updateCatProfile(
      catId: widget.cat.id,
      name: name,
      breed: breed,
      birthDate: selectedBirthDate,
      introduction: introduction,
      personalityTags: selectedPersonalities,
      imageFile: selectedImage,
      currentProfileImageUrl: widget.cat.profileImageUrl,
    );

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('고양이 프로필이 수정되었어요 🐱')));

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isVirtualCat = widget.cat.isVirtualCat;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: const Text('고양이 프로필 수정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: isVirtualCat ? null : pickCatImage,
              child: CircleAvatar(
                radius: 52,
                backgroundColor: const Color(0xFFFFE2C6),
                backgroundImage:
                    !isVirtualCat &&
                        selectedImage == null &&
                        widget.cat.profileImageUrl.isNotEmpty
                    ? NetworkImage(widget.cat.profileImageUrl)
                    : null,
                child: isVirtualCat
                    ? Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          'assets/icons/today_cat.png',
                          fit: BoxFit.contain,
                        ),
                      )
                    : selectedImage != null
                    ? ClipOval(
                        child: Image.file(
                          selectedImage!,
                          width: 104,
                          height: 104,
                          fit: BoxFit.cover,
                        ),
                      )
                    : widget.cat.profileImageUrl.isEmpty
                    ? const Icon(
                        Icons.add_a_photo_rounded,
                        color: Color(0xFF8A756C),
                        size: 30,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: nameController,
              enabled: !isVirtualCat,
              decoration: const InputDecoration(
                labelText: '고양이 이름',
                hintText: '예: 가을이',
              ),
            ),

            const SizedBox(height: 18),

            if (!isVirtualCat) ...[
              GestureDetector(
                onTap: pickBirthDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                  ),
                  child: Text(
                    birthDateText,
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedBirthDate == null
                          ? const Color(0xFF8C6A5F)
                          : const Color(0xFF3D241E),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: breedController,
                decoration: const InputDecoration(
                  labelText: '품종',
                  hintText: '예: 코리안숏헤어',
                ),
              ),

              const SizedBox(height: 18),
            ],

            if (!isVirtualCat) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '성격 선택 (최대 5개)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A2B22),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: personalityOptions.map((personality) {
                  final selected = selectedPersonalities.contains(personality);

                  return FilterChip(
                    label: Text(
                      personality,
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
                          selectedPersonalities.remove(personality);
                        } else {
                          if (selectedPersonalities.length < 5) {
                            selectedPersonalities.add(personality);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('성격은 최대 5개까지 선택할 수 있어요.'),
                              ),
                            );
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),
            ],

            TextField(
              controller: introductionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '소개',
                hintText: '우리 아이를 소개해주세요 🐾',
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitEditCatProfile,
                child: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('수정하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

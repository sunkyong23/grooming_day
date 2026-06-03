import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../utils/cat_validator.dart';

class CreateCatScreen extends StatefulWidget {
  const CreateCatScreen({super.key});

  @override
  State<CreateCatScreen> createState() => _CreateCatScreenState();
}

class _CreateCatScreenState extends State<CreateCatScreen> {
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final introductionController = TextEditingController();

  final picker = ImagePicker();

  String selectedGender = '여아';
  File? selectedImage;
  DateTime? selectedBirthDate;

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

  final List<String> selectedPersonalities = [];

  @override
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    introductionController.dispose();
    super.dispose();
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
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedBirthDate = pickedDate;
    });
  }

  String get birthDateText {
    if (selectedBirthDate == null) {
      return '생일을 선택해주세요';
    }

    return '${selectedBirthDate!.year}.${selectedBirthDate!.month.toString().padLeft(2, '0')}.${selectedBirthDate!.day.toString().padLeft(2, '0')}';
  }

  void submitCatProfile() {
    final name = nameController.text.trim();

    if (!CatValidator.isValidKoreanName(name)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('고양이 이름은 한글만 입력해주세요.')));
      return;
    }

    if (selectedBirthDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('고양이 생일을 선택해주세요.')));
      return;
    }

    if (selectedPersonalities.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('성격을 1개 이상 선택해주세요.')));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('고양이 프로필 입력 화면 준비 완료 🐱')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        title: const Text('고양이 프로필 만들기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickCatImage,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFFFFE2C6),
                backgroundImage: selectedImage != null
                    ? FileImage(selectedImage!)
                    : null,
                child: selectedImage == null
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
              decoration: const InputDecoration(
                labelText: '고양이 이름',
                hintText: '예: 가을이',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: selectedGender,
              decoration: const InputDecoration(labelText: '성별'),
              items: const [
                DropdownMenuItem(value: '여아', child: Text('여아')),
                DropdownMenuItem(value: '남아', child: Text('남아')),
                DropdownMenuItem(value: '모름', child: Text('모름')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGender = value ?? '여아';
                });
              },
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: pickBirthDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFBDBDBD))),
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
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
            const SizedBox(height: 14),
            TextField(
              controller: introductionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '소개',
                hintText: '우리 아이를 소개해주세요 🐾',
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitCatProfile,
                child: const Text('고양이 프로필 만들기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

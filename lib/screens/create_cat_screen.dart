import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../utils/cat_validator.dart';
import '../services/cat_service.dart';

import 'main_tab_screen.dart';

class CreateCatScreen extends StatefulWidget {
  final bool isFromProfile;

  const CreateCatScreen({super.key, this.isFromProfile = false});

  @override
  State<CreateCatScreen> createState() => _CreateCatScreenState();
}

class _CreateCatScreenState extends State<CreateCatScreen> {
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final introductionController = TextEditingController();

  final picker = ImagePicker();

  bool isSubmitting = false;

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

  InputDecoration inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFFD0C2BA),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFFFE4D6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Color(0xFFFFB199), width: 1.4),
      ),
    );
  }

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
    if (!mounted) return;

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
    if (!mounted) return;

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

  Future<void> submitCatProfile() async {
    if (isSubmitting) return;

    final name = nameController.text.trim();
    final breed = breedController.text.trim();

    if (selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('고양이 대표 사진을 선택해주세요.')));
      return;
    }

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

    if (!CatValidator.isValidKoreanName(name)) {
      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('고양이 이름은 한글만 입력해주세요.')));
      return;
    }

    if (selectedBirthDate == null) {
      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('고양이 생일을 선택해주세요.')));
      return;
    }

    if (breed.isEmpty) {
      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('품종을 입력해주세요.')));
      return;
    }

    if (selectedPersonalities.isEmpty) {
      setState(() {
        isSubmitting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('성격을 1개 이상 선택해주세요.')));
      return;
    }

    await CatService.createCat(
      name: name,
      breed: breed,
      gender: selectedGender,
      birthDate: selectedBirthDate,
      introduction: introductionController.text.trim(),
      personalityTags: selectedPersonalities,
      isVirtualCat: false,
      imageFile: selectedImage,
    );

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('고양이 프로필이 등록되었어요 🐱')));

    if (widget.isFromProfile) {
      Navigator.pop(context, true);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainTabScreen()),
        (route) => false,
      );
    }
  }

  Widget sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: Color(0xFF5C4033),
        ),
      ),
    );
  }

  Widget buildCatImagePicker() {
    return GestureDetector(
      onTap: pickCatImage,
      child: CircleAvatar(
        radius: 50,
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
    );
  }

  Widget birthDateField() {
    return GestureDetector(
      onTap: pickBirthDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFFFE4D6)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                birthDateText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selectedBirthDate == null
                      ? const Color(0xFFD0C2BA)
                      : const Color(0xFF5C4033),
                ),
              ),
            ),
            const Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: Color(0xFF8A756C),
            ),
          ],
        ),
      ),
    );
  }

  Widget genderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedGender,
      dropdownColor: const Color(0xFFFFF7F1),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF8A756C),
      ),
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF5C4033),
        fontWeight: FontWeight.w700,
      ),
      decoration: inputDecoration('성별'),
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
    );
  }

  Widget personalityChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: personalityOptions.map((personality) {
        final selected = selectedPersonalities.contains(personality);

        return FilterChip(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
          label: Text(
            personality,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected
                  ? const Color(0xFF5C4033)
                  : const Color(0xFF8A756C),
            ),
          ),
          selected: selected,
          showCheckmark: false,
          selectedColor: const Color(0xFFFFD9C9),
          backgroundColor: Colors.white,
          side: BorderSide(
            color: selected ? const Color(0xFFE8A58C) : const Color(0xFFE8E1DB),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          onSelected: (_) {
            setState(() {
              if (selected) {
                selectedPersonalities.remove(personality);
              } else {
                if (selectedPersonalities.length < 5) {
                  selectedPersonalities.add(personality);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('성격은 최대 5개까지 선택할 수 있어요.')),
                  );
                }
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : submitCatProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFA997),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE8D6CF),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                '고양이 프로필 만들기',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7F1),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '고양이 프로필 만들기',
          style: TextStyle(
            color: Color(0xFF5C4033),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5C4033)),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 40),
        child: Column(
          children: [
            const SizedBox(height: 20),

            buildCatImagePicker(),

            const SizedBox(height: 28),

            TextField(
              controller: nameController,
              cursorColor: const Color(0xFF5C4033),
              decoration: inputDecoration('고양이 이름'),
            ),

            const SizedBox(height: 14),

            genderDropdown(),

            const SizedBox(height: 14),

            birthDateField(),

            const SizedBox(height: 14),

            TextField(
              controller: breedController,
              cursorColor: const Color(0xFF5C4033),
              decoration: inputDecoration('품종'),
            ),

            const SizedBox(height: 26),

            sectionTitle('성격 선택 (최대 5개)'),

            const SizedBox(height: 12),

            personalityChips(),

            const SizedBox(height: 24),

            TextField(
              controller: introductionController,
              maxLines: 2,
              cursorColor: const Color(0xFF5C4033),
              decoration: inputDecoration('나의 고양이를 소개해주세요 🐾'),
            ),

            const SizedBox(height: 28),

            buildSubmitButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

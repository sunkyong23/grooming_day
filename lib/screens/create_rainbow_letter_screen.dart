import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    titleController.dispose();
    catNameController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> submitLetter() async {
    if (titleController.text.trim().isEmpty ||
        catNameController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목, 아이 이름, 내용을 모두 입력해주세요.')),
      );
      return;
    }

    try {
      await RainbowService().createLetter(
        title: titleController.text.trim(),
        catName: catNameController.text.trim(),
        content: contentController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('무지개별에 편지를 남겼어요.')));

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('편지를 저장하지 못했어요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10172A),
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
            label: '아이 이름',
            hintText: '가을이',
          ),
          const SizedBox(height: 16),
          _InputField(
            controller: contentController,
            label: '내용',
            hintText: '오늘도 네 생각이 났어.',
            maxLines: 12,
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: submitLetter,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFDCA8),
              foregroundColor: const Color(0xFF3D241E),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              '무지개별에 남기기',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
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

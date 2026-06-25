import 'package:flutter/material.dart';

import '../../data/catti_questions.dart';
import '../../models/catti_question.dart';
import '../../services/catti_service.dart';
import 'catti_loading_screen.dart';

class CattiTestScreen extends StatefulWidget {
  final String catProfileId;
  final String catName;

  const CattiTestScreen({
    super.key,
    required this.catProfileId,
    required this.catName,
  });

  @override
  State<CattiTestScreen> createState() => _CattiTestScreenState();
}

class _CattiTestScreenState extends State<CattiTestScreen> {
  int currentIndex = 0;
  CattiOption? selectedOption;

  final Map<String, CattiOption> answers = {};

  CattiQuestion get currentQuestion => cattiQuestions[currentIndex];

  void goNext() {
    if (selectedOption == null) return;

    answers[currentQuestion.id] = selectedOption!;

    if (currentIndex == cattiQuestions.length - 1) {
      final result = CattiService().calculateResult(answers);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CattiLoadingScreen(
            catProfileId: widget.catProfileId,
            catName: widget.catName,
            result: result,
            answers: answers,
          ),
        ),
      );
      return;
    }

    setState(() {
      currentIndex++;
      selectedOption = answers[cattiQuestions[currentIndex].id];
    });
  }

  void goPrevious() {
    if (currentIndex == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      currentIndex--;
      selectedOption = answers[cattiQuestions[currentIndex].id];
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = currentQuestion;
    final progress = (currentIndex + 1) / cattiQuestions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F4),
        elevation: 0,
        foregroundColor: const Color(0xFF3D241E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: goPrevious,
        ),
        title: Text('${currentIndex + 1} / ${cattiQuestions.length}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF3DDD3),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFE8A58C)),
                ),
              ),
              const SizedBox(height: 34),
              Text(question.icon, style: const TextStyle(fontSize: 42)),
              const SizedBox(height: 14),
              Text(
                question.category,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFB48A78),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                question.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1.3,
                  color: Color(0xFF3D241E),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.separated(
                  itemCount: question.options.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final option = question.options[index];
                    final selected = selectedOption?.id == option.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedOption = option;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFFFE4D6)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFE8A58C)
                                : const Color(0xFFF0D5CA),
                            width: selected ? 1.4 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.text,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.35,
                                  color: const Color(0xFF3D241E),
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (selected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFFE8A58C),
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedOption == null
                        ? const Color(0xFFE8D8D0)
                        : const Color(0xFFFFD9C9),
                    foregroundColor: const Color(0xFF3D241E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: selectedOption == null ? null : goNext,
                  child: Text(
                    currentIndex == cattiQuestions.length - 1 ? '결과 보기' : '다음',
                    style: const TextStyle(
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

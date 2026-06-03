import 'package:flutter/material.dart';

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

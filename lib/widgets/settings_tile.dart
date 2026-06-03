import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final VoidCallback onTap;

  const SettingsTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: const Row(
          children: [
            Icon(Icons.settings_rounded, color: Color(0xFF8A756C)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '설정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D241E),
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Color(0xFFB08678)),
          ],
        ),
      ),
    );
  }
}

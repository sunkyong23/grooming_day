import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final IconData icon;

  const SettingsTile({
    super.key,
    required this.onTap,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF8A756C)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D241E),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB08678)),
          ],
        ),
      ),
    );
  }
}

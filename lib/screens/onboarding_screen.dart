import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main_tab_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool isLoading = false;

  Future<void> completeOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'hasSeenOnboarding': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainTabScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F1),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/home_onboarding.png',
                fit: BoxFit.cover,
              ),
            ),

            Positioned(
              left: 24,
              right: 24,
              bottom: 28,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD9C9),
                    disabledBackgroundColor: const Color(0xFFE6C8BE),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Color(0xFF5C4033),
                          ),
                        )
                      : const Text(
                          '확인했어요',
                          style: TextStyle(
                            color: Color(0xFF3D241E),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

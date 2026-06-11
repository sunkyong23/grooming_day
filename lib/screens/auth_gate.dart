import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'main_tab_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> isSuspendedUser(User user) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = userDoc.data();

    return data?['isSuspended'] == true;
  }

  Future<void> signOutSuspendedUser() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        return FutureBuilder<bool>(
          future: isSuspendedUser(user),
          builder: (context, suspendedSnapshot) {
            if (suspendedSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isSuspended = suspendedSnapshot.data == true;

            if (isSuspended) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await signOutSuspendedUser();

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('정지된 계정입니다. 앱을 이용할 수 없어요.')),
                );
              });

              return const LoginScreen();
            }

            return const MainTabScreen();
          },
        );
      },
    );
  }
}

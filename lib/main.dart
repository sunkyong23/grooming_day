import 'package:flutter/material.dart';

void main() {
  runApp(const GroomingDayApp());
}

class GroomingDayApp extends StatelessWidget {
  const GroomingDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFDF7F4),
        body: Center(
          child: Text(
            '그루밍데이 🐱',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

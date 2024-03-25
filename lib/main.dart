import 'package:flutter/material.dart';
import '/workspace/modeSelector.dart'; // Ensure this import matches your project structure

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: const Center(
          child: ModeSelector(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

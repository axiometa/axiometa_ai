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
      title: 'Flutter Demo',
      theme: ThemeData(
        // Set the primary color
        primaryColor: Colors.white, // Sets the background color of the App Bar
        scaffoldBackgroundColor: Colors.white, // Sets the default background color of the Scaffold
        // Since white is not a swatch, we do not use primarySwatch here
        // Define other theme properties as needed
      ),
      home: Scaffold(
        body: const Center(
          child: ModeSelector(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

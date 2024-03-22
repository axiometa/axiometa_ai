import 'package:flutter/material.dart';
import '/IDELikeInterface.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  //comment FROM WINDOWS
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: IDELikeInterface(),
      debugShowCheckedModeBanner: false,
    );
  }
}


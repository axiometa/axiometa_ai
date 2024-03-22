import 'package:flutter/material.dart';


class ComponentData {
  String name;
  Offset position;
  List<ComponentData> connections = [];
  String imagePath; // New field for the image path

  ComponentData({
    required this.name,
    required this.position,
    required this.imagePath, // Initialize in the constructor
  });
}
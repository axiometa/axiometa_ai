import 'package:flutter/material.dart';

class ComponentLibrary extends StatelessWidget {
  final Function(String, Offset) onComponentSelected;

  ComponentLibrary({super.key, required this.onComponentSelected});

  final List<String> components = [
    'Arduino Nano',
    'Sensor DHT11',
    'Sensor BMP180',
    // Add more components as needed
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: components.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(components[index]),
          onTap: () =>
              onComponentSelected(components[index], const Offset(100, 100)),
        );
      },
    );
  }
}

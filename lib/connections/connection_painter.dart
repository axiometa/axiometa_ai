import 'package:flutter/material.dart';
import '../components/component_data.dart';

class ConnectionPainter extends CustomPainter {
  final List<ComponentData> components;

  ConnectionPainter(this.components);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (var component in components) {
      for (var connection in component.connections) {
        canvas.drawLine(component.position, connection.position, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
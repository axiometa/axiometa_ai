import 'package:flutter/material.dart';
import '../components/component_data.dart';

class ConnectionPainter extends CustomPainter {
  final List<ComponentData> components;
  final Offset startOffset;
  final double componentWidth;
  final double componentHeight;

  ConnectionPainter(this.components,
      {this.startOffset = Offset.zero,
      this.componentWidth = 100, // Example width, replace with actual value
      this.componentHeight = 100, // Example height, replace with actual value
      });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (var component in components) {
      for (var connection in component.connections) {
        // Adjusting start and end points with offsets
        final startPoint = Offset(
          component.position.dx + startOffset.dx + componentWidth / 2,
          component.position.dy + startOffset.dy + componentHeight / 2,
        );
        final endPoint = Offset(
          connection.position.dx + startOffset.dx + componentWidth / 2,
          connection.position.dy + startOffset.dy + componentHeight / 2,
        );
        canvas.drawLine(startPoint, endPoint, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

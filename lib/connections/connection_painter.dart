import 'package:flutter/material.dart';
import '../components/component_data.dart';

class InteractiveViewerWrapper extends StatelessWidget {
  final List<ComponentData> components;
  final Offset startOffset;
  final double componentWidth;
  final double componentHeight;

  InteractiveViewerWrapper({
    Key? key,
    required this.components,
    this.startOffset = Offset.zero,
    this.componentWidth = 100,
    this.componentHeight = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        // Determine the tap position
        RenderBox renderBox = context.findRenderObject() as RenderBox;
        final position = renderBox.globalToLocal(details.globalPosition) - startOffset;

        // Check if the tap position is close to any line
        for (var component in components) {
          for (var connection in component.connections) {
            final startPoint = component.position + Offset(componentWidth / 2, componentHeight / 2);
            final endPoint = connection.position + Offset(componentWidth / 2, componentHeight / 2);

            if (isTapOnLine(startPoint, endPoint, position)) {
              // If tap is detected on a line, show a dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Connection Info'),
                    content: Text('You tapped on the wire between ${component.name} and ${connection.name}.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
              break;
            }
          }
        }
      },
      child: CustomPaint(
        painter: ConnectionPainter(
          components,
          startOffset: startOffset,
          componentWidth: componentWidth,
          componentHeight: componentHeight,
        ),
        size: Size.infinite,
      ),
    );
  }

  bool isTapOnLine(Offset p1, Offset p2, Offset tapPosition, {double threshold = 10.0}) {
    // Calculate the distance from the tap position to the line segment
    double distanceToLine = distanceToSegment(p1, p2, tapPosition);
    return distanceToLine < threshold;
  }

double distanceToSegment(Offset p1, Offset p2, Offset tapPosition) {
  final double l2 = (p2 - p1).distanceSquared;
  // If line length is 0, it's a point, so return distance to the point
  if (l2 == 0) return (tapPosition - p1).distance;

  // Calculate t, the projection scalar of tapPosition on the line p1->p2
  final double t = ((tapPosition - p1).dx * (p2 - p1).dx + (tapPosition - p1).dy * (p2 - p1).dy) / l2;

  // Determine the closest point on the segment to the tapPosition
  Offset projection;
  if (t < 0) {
    projection = p1; // Before p1 on the line
  } else if (t > 1) {
    projection = p2; // Past p2 on the line
  } else {
    projection = p1 + Offset((p2 - p1).dx * t, (p2 - p1).dy * t); // Projection falls on the segment
  }

  // Return the distance from tapPosition to the closest point on the segment
  return (tapPosition - projection).distance;
}

}

class ConnectionPainter extends CustomPainter {
  final List<ComponentData> components;
  final Offset startOffset;
  final double componentWidth;
  final double componentHeight;

  // Default values are provided, making the named parameters optional
  ConnectionPainter(
    this.components, {
    this.startOffset = Offset.zero, // Default value
    this.componentWidth = 100.0,    // Default value, replace with your desired default
    this.componentHeight = 100.0,   // Default value, replace with your desired default
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5;

    for (var component in components) {
      for (var connection in component.connections) {
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

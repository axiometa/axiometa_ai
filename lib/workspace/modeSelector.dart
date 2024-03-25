import 'package:flutter/material.dart';
import '/workspace/workspace.dart'; // Ensure this import matches your project structure
import '/workspace/workspace2.dart'; // Ensure this import matches your project structure

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key});

  void selectMode(BuildContext context, int mode) {
    if (mode == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const workspace()));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            // This dialog can be replaced or updated to handle more complex input
            return AlertDialog(
              title: const Text("Choose what to build"),
              content: TextField(
                onSubmitted: (value) {
                  if (value.contains("DHT11")) {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const workspace2()));
                  }
                },
              ),
            );
          });
    }
  }


  @override
Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => selectMode(context, 1),
          child: const Text('Software Development Mode'),
        ),
        ElevatedButton(
          onPressed: () => selectMode(context, 2),
          child: const Text('Electronics Prototyping Prompts Mode'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '/workspace/workspace.dart'; // Ensure this import matches your project structure
import '/workspace/workspace2.dart'; // Ensure this import matches your project structure

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key});

  void selectMode(BuildContext context, int mode) {
    if (mode == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const workspace()));
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const workspace2()));
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
        Padding(
          padding:
              const EdgeInsets.only(bottom: 20), // Adjust the space as needed
          child: Text(
            "Welcome to Axiometa AI",
            style: TextStyle(
              fontFamily: 'Pirulen', // Use your custom font
              fontSize: 32, // Adjust the font size as needed
              fontWeight: FontWeight.bold, // Adjust the weight as needed
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the buttons horizontally
          children: [
            _buildCustomButton(
              context: context,
              onTap: () => selectMode(context, 1),
              logoColor: Color.fromARGB(255, 16, 132, 226),
              iconData: Icons.computer, // Example icon for Software Development
              text: 'Software - Development Mode',
            ),
            SizedBox(width: 8), // Correct horizontal space between buttons
            _buildCustomButton(
              context: context,
              onTap: () => selectMode(context, 2),
              logoColor: Color.fromARGB(255, 153, 39, 39),
              iconData:
                  Icons.memory, // Example icon for Electronics Development
              text: 'Electronics - Development Mode',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomButton({
    required BuildContext context,
    required VoidCallback onTap,
    required Color logoColor,
    required IconData iconData, // New parameter for icon
    required String text,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 130.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: logoColor,
                borderRadius:
                    BorderRadius.circular(16), // This gives a square look
              ),
              child: Icon(iconData,
                  color: Color.fromARGB(255, 4, 0, 0),
                  size: 40), // Use the passed icon data here
            ),
            SizedBox(width: 16), // Space between the icon and the text
            Text(text),
          ],
        ),
      ),
    );
  }
}

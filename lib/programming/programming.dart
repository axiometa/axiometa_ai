import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import '/components/component_data.dart';
import 'generated_code.dart'; // Adjust the path according to your file structure
// You might need to add additional imports for clipboard functionality or file uploads

void showProgrammingDialog(BuildContext context, ComponentData component, Function(String) onCodeGenerated) {
  TextEditingController customController = TextEditingController();
  String previewCode = '';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder( // Use StatefulBuilder to update the preview
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Program ${component.name}"),
            content: SingleChildScrollView( // Use SingleChildScrollView for larger content
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: customController,
                    decoration: const InputDecoration(hintText: "Enter your action"),
                    onChanged: (value) {
                      // Update preview code on text change
                      if (value.contains("DHT11")) {
                        setState(() {
                          previewCode = getGeneratedCode_DHT11(); // This function should ideally use the input to generate code dynamically
                        });
                      }
                      if (value.contains("BMP180")) {
                        setState(() {
                          previewCode = getGeneratedCode_BMP180(); // This function should ideally use the input to generate code dynamically
                        });
                      }
                      if (value.contains("BMP180") && value.contains("DHT11")) {
                        setState(() {
                          previewCode = getGeneratedCode_DHT11_BMP180(); // This function should ideally use the input to generate code dynamically
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text("Preview:"),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: HighlightView(
                      previewCode,
                      language: 'dart',
                      theme: githubTheme,
                      padding: const EdgeInsets.all(8.0),
                      textStyle: const TextStyle(fontFamily: 'Monospace', fontSize: 10.0),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text("Copy to Clipboard"),
                onPressed: () {
                  // Implement clipboard copy logic here
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Upload"),
                onPressed: () {
                  // Implement upload logic here
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Generate"),
                onPressed: () {
                  if (previewCode.isNotEmpty) {
                    onCodeGenerated(previewCode);
                    Navigator.of(context).pop();
                  } else {
                    // Handle error or invalid input
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a valid action to generate code.")),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}

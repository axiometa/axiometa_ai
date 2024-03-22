import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services for clipboard access
import 'dart:async'; // For timer functions

import '/components/component_library.dart';
import '/connections/connection_painter.dart';
import '/components/component_data.dart';
import '/programming/programming.dart';

class IDELikeInterface extends StatefulWidget {
  const IDELikeInterface({super.key});

  @override
  IDELikeInterfaceState createState() => IDELikeInterfaceState();
}

class IDELikeInterfaceState extends State<IDELikeInterface> {
  List<ComponentData> componentsInWorkspace = [];
  final GlobalKey workspaceKey = GlobalKey();
  ComponentData? selectedComponent;
  bool isDeleteMode = false;
  bool isProgrammingMode = false; // Flag for Programming Mode
  String generatedCode = '// Your code will appear here';

  addComponentToWorkspace(String componentName, Offset position) {
    setState(() {
      componentsInWorkspace.add(
        ComponentData(
          name: componentName,
          position: position,
          imagePath: 'assets/images/sensor_icons/$componentName.png', // Example path
        ),
      );
    });
  }

  void onComponentTap(ComponentData component) {
    if (isProgrammingMode) {
      if (component.name == "Arduino Nano") {
        showProgrammingDialog(context, component, updateGeneratedCode);
      }
    } else if (!isDeleteMode) {
      if (selectedComponent == null) {
        selectedComponent = component;
      } else if (selectedComponent != component) {
        selectedComponent!.connections.add(component);
        selectedComponent = null;
      }
    } else {
      setState(() {
        componentsInWorkspace.remove(component);
      });
    }
    setState(() {});
  }

  void updateGeneratedCode(String code) {
    setState(() {
      generatedCode = code;
    });
  }

  void onComponentDropped(ComponentData component, Offset globalOffset) {
    final RenderBox renderBox = workspaceKey.currentContext!.findRenderObject()! as RenderBox;
    final Offset localOffset = renderBox.globalToLocal(globalOffset);
    setState(() {
      component.position = localOffset;
    });
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: generatedCode)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code copied to clipboard!')),
      );
    });
  }

  void showUploadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button for close dialog!
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pop(true);
        });
        return AlertDialog(
          title: Text('Uploading'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Simulating upload to Arduino...'),
                SizedBox(height: 20),
                LinearProgressIndicator(),
              ],
            ),
          ),
        );
      },
    ).then((val) {
      if (val) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload complete!')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AXIOMETA', style: TextStyle(color: Colors.white, fontFamily: 'Pirulen')),
        backgroundColor: Color.fromARGB(255, 5, 19, 12),
        actions: [
          if (!isProgrammingMode)
            IconButton(
              icon: Icon(isDeleteMode ? Icons.edit : Icons.delete),
              onPressed: () => setState(() => isDeleteMode = !isDeleteMode),
              tooltip: isDeleteMode ? 'Switch to Edit Mode' : 'Switch to Delete Mode',
              color: Colors.white,
            ),
          IconButton(
            icon: Icon(isProgrammingMode ? Icons.code_off : Icons.code),
            onPressed: () => setState(() {
              isProgrammingMode = !isProgrammingMode;
              if (isProgrammingMode) {
                isDeleteMode = false;
              }
            }),
            tooltip: isProgrammingMode ? 'Exit Programming Mode' : 'Enter Programming Mode',
            color: Colors.white,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(generatedCode, style: const TextStyle(fontFamily: 'Monospace', fontSize: 16)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showUploadDialog(); // Simulate upload functionality
                    },
                    child: const Text('Upload'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                  ),
                  SizedBox(height: 10), // Adjusted spacing to 10px
                  ElevatedButton(
                    onPressed: copyToClipboard, // Implement copy to clipboard functionality
                    child: const Text('Copy to Clipboard'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => setState(() => selectedComponent = null),
              child: Container(
                key: workspaceKey,
                color: Colors.white,
                child: CustomPaint(
                  painter: ConnectionPainter(componentsInWorkspace),
                  child: Stack(
                    children: componentsInWorkspace.map((component) {
                      return Positioned(
                        left: component.position.dx,
                        top: component.position.dy,
                        child: Draggable<ComponentData>(
                          data: component,
                          feedback: Material(
                            elevation: 4.0,
                            child: Image.asset(component.imagePath, width: 150, height: 150), // Adjust size as needed
                          ),
                          onDragEnd: (details) => onComponentDropped(component, details.offset),
                          child: GestureDetector(
                            onTap: () => onComponentTap(component),
                            child: Stack(
                              children: [
                                Image.asset(component.imagePath, width: 120, height: 120), // Base Image
                                if (selectedComponent == component) // Conditional blue overlay
                                  Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.blue.withOpacity(0.5),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              child: ComponentLibrary(
                onComponentSelected: (componentName, position) => addComponentToWorkspace(componentName, const Offset(100, 100)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

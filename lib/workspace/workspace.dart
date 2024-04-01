import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services for clipboard access
import 'package:url_launcher/url_launcher.dart';

import 'dart:async'; // For timer functions

import '/components/component_library.dart';
import '/connections/connection_painter.dart';
import '/components/component_data.dart';
import '/programming/programming.dart';
import '/sensor_connections/sensor_connection.dart';

class workspace extends StatefulWidget {
  const workspace({super.key});

  @override
  workspaceState createState() => workspaceState();
}

class workspaceState extends State<workspace> {
  List<ComponentData> componentsInWorkspace = [];
  final GlobalKey workspaceKey = GlobalKey();
  ComponentData? selectedComponent;
  bool isDeleteMode = false;
  bool isProgrammingMode = false; // Flag for Programming Mode
  String generatedCode = 'Code will appear here';
  String? _selectedOption; // This will hold the currently selected dropdown option.
  List<String> _options = []; // This will hold the dropdown options.

 @override
  void initState() {
    super.initState();
    _options = ['Basic Arduino', 'Bare Arduino', 'STM32', 'Other...'];
    _selectedOption = _options.first;
  }

  addComponentToWorkspace(String componentName, Offset position) {
    setState(() {
      componentsInWorkspace.add(
        ComponentData(
          name: componentName,
          position: position,
          imagePath:
              'assets/images/sensor_icons/$componentName.png', // Example path
        ),
      );
    });
  }

  void onComponentTap(ComponentData component) {
    if (isProgrammingMode) {
      if (component.name == "Axiometa Sparklet") {
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
    final RenderBox renderBox =
        workspaceKey.currentContext!.findRenderObject()! as RenderBox;
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

  void openStore(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Bellow are the required parts for your prototype"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Adjust the image paths as needed
              Image.asset('assets/images/sensor_icons/Axiometa Sparklet.png',
                  width: 100),
              Image.asset('assets/images/sensor_icons/Sensor DHT11.png',
                  width: 100),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Purchase online"),
              onPressed: () async {
                const url =
                    'https://axiometa.ai/product/dht11-temperature-and-humidity-sensor/';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
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
                Text('Uploading to Axiometa Sparklet (COM3)'),
                SizedBox(height: 20),
                LinearProgressIndicator(),
              ],
            ),
          ),
        );
      },
    ).then((val) {
      if (val) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload complete!')));
      }
    });
  }

  double distanceToSegment(Offset p1, Offset p2, Offset tapPosition) {
    final double l2 = (p2 - p1).distanceSquared;
    // If line length is 0, it's a point, so return distance to the point
    if (l2 == 0) return (tapPosition - p1).distance;

    // Calculate t, the projection scalar of tapPosition on the line p1->p2
    final double t = ((tapPosition - p1).dx * (p2 - p1).dx +
            (tapPosition - p1).dy * (p2 - p1).dy) /
        l2;

    // Determine the closest point on the segment to the tapPosition
    Offset projection;
    if (t < 0) {
      projection = p1; // Before p1 on the line
    } else if (t > 1) {
      projection = p2; // Past p2 on the line
    } else {
      projection = p1 +
          Offset((p2 - p1).dx * t,
              (p2 - p1).dy * t); // Projection falls on the segment
    }

    // Return the distance from tapPosition to the closest point on the segment
    return (tapPosition - projection).distance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AXIOMETA',
          style: TextStyle(color: Colors.white, fontFamily: 'Pirulen'),
        ),
        backgroundColor: Color.fromARGB(255, 5, 19, 12),
        iconTheme: IconThemeData(
          color: Colors
              .white, // This will apply to the back button and other icon buttons in the AppBar
        ),
        actions: [
          if (!isProgrammingMode)
            IconButton(
              icon: Icon(isDeleteMode ? Icons.edit : Icons.delete),
              onPressed: () => setState(() => isDeleteMode = !isDeleteMode),
              tooltip: isDeleteMode
                  ? 'Switch to Edit Mode'
                  : 'Switch to Delete Mode',
            ),
          IconButton(
            icon: Icon(isProgrammingMode ? Icons.code_off : Icons.code),
            onPressed: () => setState(() {
              isProgrammingMode = !isProgrammingMode;
              if (isProgrammingMode) {
                isDeleteMode = false;
              }
            }),
            tooltip: isProgrammingMode
                ? 'Exit Programming Mode'
                : 'Enter Programming Mode',
          ),
          // New settings button
          IconButton(
            icon: Icon(Icons.store),
            onPressed: () {
              openStore(context);
            },
            tooltip: 'Store',
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Your settings button event
            },
            tooltip: 'Settings',
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    // DropdownButton widget here
                    child: DropdownButton<String>(
                      value: _selectedOption,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedOption = newValue;
                        });
                      },
                      items: _options
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey[100], // IDE-like background color
                          child: TextField(
                            controller:
                                TextEditingController(text: generatedCode),
                            style: const TextStyle(
                              fontFamily:
                                  'Monospace', // Use a monospace font for code-like appearance
                              fontSize: 16,
                              color: Color.fromARGB(255, 0, 0,
                                  0), // Text color that contrasts with the background
                            ),
                            maxLines: null, // Allow for any number of lines
                            decoration: InputDecoration(
                              border:
                                  InputBorder.none, // Hide the TextField border
                              contentPadding: EdgeInsets.zero, // Remove padding
                            ),
                            onChanged: (newCode) {
                              updateGeneratedCode(
                                  newCode); // Update the generatedCode variable when text changes
                            },
                            enableInteractiveSelection:
                                true, // Allows text selection
                            cursorColor: Colors.black, // Cursor color
                          ),
                        ),
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      showUploadDialog(); // Simulate upload functionality
                    },
                    child: const Text('Upload'),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40)),
                  ),
                  SizedBox(height: 10), // Adjusted spacing to 10px
                  ElevatedButton(
                    onPressed:
                        copyToClipboard, // Implement copy to clipboard functionality
                    child: const Text('Copy to Clipboard'),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTapUp: (TapUpDetails details) {
                final RenderBox renderBox = workspaceKey.currentContext!
                    .findRenderObject() as RenderBox;
                final Offset localPosition =
                    renderBox.globalToLocal(details.globalPosition);

                bool hitLine = false;
                for (var component in componentsInWorkspace) {
                  for (var connection in component.connections) {
                    final Offset startPoint =
                        component.position + Offset(100 / 2, 100 / 2);
                    final Offset endPoint =
                        connection.position + Offset(100 / 2, 100 / 2);

                    if (distanceToSegment(startPoint, endPoint, localPosition) <
                        5) {
                      String diagramText;
                      if (component.name == "Sensor DHT11" ||
                          connection.name == "Sensor DHT11") {
                        diagramText = diagramText_DHT11;
                      } else if (component.name == "Sensor BMP180" ||
                          component.name == "Sensor BMP180") {
                        diagramText = diagramText_BMP180;
                      } else {
                        diagramText = "Unknown component";
                      }

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Connection Info'),
                            content: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16), // Default text style
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          'Tapped on wire connecting ${component.name} and ${connection.name}.\n\n'),
                                  TextSpan(
                                      text: diagramText,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
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
                      hitLine = true;
                      break; // Stop checking after a hit is found
                    }
                  }
                  if (hitLine) break;
                }

                if (!hitLine) {
                  // If no line was hit, handle the tap as a workspace tap
                  setState(() => selectedComponent = null);
                }
              },
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
                            child: Image.asset(component.imagePath,
                                width: 100,
                                height: 100), // Adjust size as needed
                          ),
                          onDragEnd: (details) =>
                              onComponentDropped(component, details.offset),
                          child: GestureDetector(
                            onTap: () => onComponentTap(component),
                            child: Stack(
                              children: [
                                Image.asset(component.imagePath,
                                    width: 100, height: 100), // Base Image
                                if (selectedComponent ==
                                    component) // Conditional blue overlay
                                  Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.blue.withOpacity(0.8),
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
                onComponentSelected: (componentName, position) =>
                    addComponentToWorkspace(
                        componentName, const Offset(100, 100)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '/component_library.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  //comment FROM WINDOWS
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: IDELikeInterface(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IDELikeInterface extends StatefulWidget {
  const IDELikeInterface({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IDELikeInterfaceState createState() => _IDELikeInterfaceState();
}

class _IDELikeInterfaceState extends State<IDELikeInterface> {
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
    //new comment
    if (isProgrammingMode) {
      // Trigger programming dialog only in Programming Mode
      if (component.name == "Arduino Nano") {
        showProgrammingDialog(component);
      }
    } else if (!isDeleteMode) {
      if (selectedComponent == null) {
        selectedComponent = component;
      } else if (selectedComponent != component) {
        selectedComponent!.connections.add(component);
        selectedComponent = null;
      }
    } else {
      // Handle delete mode
      setState(() {
        componentsInWorkspace.remove(component);
      });
    }
    setState(() {});
  }

  void showProgrammingDialog(ComponentData component) {
    TextEditingController customController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Program ${component.name}"),
          content: TextField(
            controller: customController,
            decoration: const InputDecoration(hintText: "Enter your action"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Generate"),
              onPressed: () {
                // For simplicity, directly set the generated code. In a real app, you might analyze the input.
                generateCodeForArduino(customController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void generateCodeForArduino(String action) {
    // Example generation logic. Customize as needed.
    if (action.contains("DHT11")) {
      setState(() {
        generatedCode = """
//Generated code
#include <DHT.h>
#define DHTPIN 2 // Pin connected to the DHT sensor
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);
void setup() {
  Serial.begin(9600);
  dht.begin();
}
void loop() {
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  if (isnan(h) || isnan(t)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }
  Serial.print("Humidity: ");
  Serial.print(h);
  Serial.print("%\t");
  Serial.print("Temperature: ");
  Serial.print(t);
  Serial.println("°C");
  delay(2000);
}
""";
      });
    }
  }

  void onComponentDropped(ComponentData component, Offset globalOffset) {
    final RenderBox renderBox =
        workspaceKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localOffset = renderBox.globalToLocal(globalOffset);
    setState(() {
      component.position = localOffset;
    });
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
        actions: [
          if (!isProgrammingMode)
            IconButton(
              //message comment
              icon: Icon(isDeleteMode ? Icons.edit : Icons.delete),
              onPressed: () => setState(() => isDeleteMode = !isDeleteMode),
              tooltip: isDeleteMode
                  ? 'Switch to Edit Mode'
                  : 'Switch to Delete Mode',
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
            tooltip: isProgrammingMode
                ? 'Exit Programming Mode'
                : 'Enter Programming Mode',
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
              child: SingleChildScrollView(
                child: Text(generatedCode,
                    style:
                        const TextStyle(fontFamily: 'Monospace', fontSize: 16)),
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
              if (selectedComponent == component) // Conditionally add a blue overlay
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
                  onComponentSelected: (componentName, position) =>
                      addComponentToWorkspace(
                          componentName, const Offset(100, 100))),
            ),
          ),
        ],
      ),
    );
  }
}

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
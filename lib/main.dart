import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IDELikeInterface(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IDELikeInterface extends StatefulWidget {
  @override
  _IDELikeInterfaceState createState() => _IDELikeInterfaceState();
}

class _IDELikeInterfaceState extends State<IDELikeInterface> {
  List<ComponentData> componentsInWorkspace = [];
  final GlobalKey workspaceKey = GlobalKey();
  ComponentData? selectedComponent;
  bool isDeleteMode = false;
  bool isProgrammingMode = false; // Flag for Programming Mode
  String generatedCode = '// Your code will appear here';

  void addComponentToWorkspace(String componentName, Offset position) {
    setState(() {
      componentsInWorkspace
          .add(ComponentData(name: componentName, position: position));
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
            decoration: InputDecoration(hintText: "Enter your action"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Generate"),
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
        title: Text(
          'AXIOMETA IDE',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 7, 64, 31),
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
                isDeleteMode =
                    false;
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
                    style: TextStyle(fontFamily: 'Monospace', fontSize: 16)),
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
                          child: GestureDetector(
                            onTap: () => onComponentTap(component),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              color: selectedComponent == component &&
                                      !isDeleteMode &&
                                      !isProgrammingMode
                                  ? Colors.blue
                                  : Colors.grey[200],
                              child: Text(component.name),
                            ),
                          ),
                          feedback: Material(
                            child: Text(component.name),
                            elevation: 4.0,
                          ),
                          onDragEnd: (details) =>
                              onComponentDropped(component, details.offset),
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
                      addComponentToWorkspace(componentName, Offset(100, 100))),
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

  ComponentData({required this.name, required this.position});
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

class ComponentLibrary extends StatelessWidget {
  final Function(String, Offset) onComponentSelected;

  ComponentLibrary({required this.onComponentSelected});

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
          onTap: () => onComponentSelected(components[index], Offset(100, 100)),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import '/components/component_data.dart';

void showProgrammingDialog(BuildContext context, ComponentData component, Function(String) onCodeGenerated) {
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
              if (customController.text.contains("DHT11")) {
                String generatedCode = """
//Generated code
#include <DHT.h>
#define DHTPIN 2
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
                onCodeGenerated(generatedCode);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

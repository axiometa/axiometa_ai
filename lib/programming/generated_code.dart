// lib/generated_code_template.dart

String getGeneratedCode_BMP180() {
  return """
#include <Wire.h>
#include <Adafruit_BMP085.h>

Adafruit_BMP085 bmp;

void setup() {
  Serial.begin(9600);
  if (!bmp.begin()) {
    Serial.println("Could not find BMP180 or BMP085 sensor!");
    while (1) {}
  }
}

void loop() {
  Serial.print("Temperature: ");
  Serial.print(bmp.readTemperature());
  Serial.println(" °C");

  Serial.print("Pressure: ");
  Serial.print(bmp.readPressure());
  Serial.println(" Pa");

  delay(1000);
}
""";
}

String getGeneratedCode_DHT11() {
  return """
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
  Serial.print("%\\t");
  Serial.print("Temperature: ");
  Serial.print(t);
  Serial.println("°C");
  delay(2000);
}
""";
}

String getGeneratedCode_DHT11_BMP180() {
  return """
#include <Wire.h>
#include <Adafruit_BMP085.h>
#include <DHT.h>

#define DHTPIN 2       // Digital pin connected to the DHT sensor
#define DHTTYPE DHT11  // DHT 11

DHT dht(DHTPIN, DHTTYPE);

Adafruit_BMP085 bmp;

void setup() {
  Serial.begin(9600);
  if (!bmp.begin()) {
    Serial.println("Could not find BMP180 or BMP085 sensor!");
    while (1) {}
  }
  dht.begin();
}

void loop() {
  Serial.print("Temperature (BMP180): ");
  Serial.print(bmp.readTemperature());
  Serial.println(" °C");

  Serial.print("Pressure: ");
  Serial.print(bmp.readPressure());
  Serial.println(" Pa");

  // Reading temperature and humidity from DHT11
  float humidity = dht.readHumidity();
  float temperatureDHT = dht.readTemperature();

  Serial.print("Temperature (DHT11): ");
  Serial.print(temperatureDHT);
  Serial.println(" °C");

  Serial.print("Humidity: ");
  Serial.print(humidity);
  Serial.println(" %");

  delay(1000);
}
""";
}

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensor Data Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SensorHomePage(),
    );
  }
}

class SensorHomePage extends StatefulWidget {
  const SensorHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SensorHomePageState createState() => _SensorHomePageState();
}

class _SensorHomePageState extends State<SensorHomePage> {
  double accelX = 0.0, accelY = 0.0, accelZ = 0.0;
  double gyroX = 0.0, gyroY = 0.0, gyroZ = 0.0;
  double magX = 0.0, magY = 0.0, magZ = 0.0;

  // Variablen für Neigung
  double pitch = 0.0; // rechts links neigen
  double roll = 0.0;  // vorne hinten neigen

  @override
  void initState() {
    super.initState();

    //Beschleunigungssensor (Accelerometer)
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        accelX = event.x;
        accelY = event.y;
        accelZ = event.z;

        // Berechnung von Pitch und Roll
        pitch = atan2(event.y, sqrt(event.x * event.x + event.z * event.z)) * (180 / pi);
        roll = atan2(event.x, sqrt(event.y * event.y + event.z * event.z)) * (180 / pi);
      });
    });

    //Gyroskop
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        gyroX = event.x;
        gyroY = event.y;
        gyroZ = event.z;
      });
    });

    //Magnetometer
    magnetometerEvents.listen((MagnetometerEvent event) {
      setState(() {
        magX = event.x;
        magY = event.y;
        magZ = event.z;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mehrere Sensoren auslesen'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Beschleunigungssensor (Accelerometer)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('X: ${accelX.toStringAsFixed(2)}'),
              Text('Y: ${accelY.toStringAsFixed(2)}'),
              Text('Z: ${accelZ.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              const Text(
                'Gyroskop (Gyroscope)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('X: ${gyroX.toStringAsFixed(2)}'),
              Text('Y: ${gyroY.toStringAsFixed(2)}'),
              Text('Z: ${gyroZ.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              const Text(
                'Magnetometer',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('X: ${magX.toStringAsFixed(2)}'),
              Text('Y: ${magY.toStringAsFixed(2)}'),
              Text('Z: ${magZ.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              const Text(
                'Neigung',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('Nickwinkel (Pitch): ${pitch.toStringAsFixed(2)}°'),
              Text('Rollwinkel (Roll): ${roll.toStringAsFixed(2)}°'),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  double accelX = 0.0, accelY = 0.0, accelZ = 0.0;
  double gyroX = 0.0, gyroY = 0.0, gyroZ = 0.0;
  double magX = 0.0, magY = 0.0, magZ = 0.0;
  double pitch = 0.0; //Lenkradneigung
  double roll = 0.0;  //nach vorne / zu einem kippen

  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
  late StreamSubscription<MagnetometerEvent> _magnetometerSubscription;

  @override
  void initState() {
    super.initState();

    //Init verschiedene Sensoren
    //Acceleromenter
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          accelX = event.x;
          accelY = event.y;
          accelZ = event.z;

          //Gelesene Neigungen umrechnen
          pitch = atan2(event.y, sqrt(event.x * event.x + event.z * event.z)) * (180 / pi);
          roll = atan2(event.x, sqrt(event.y * event.y + event.z * event.z)) * (180 / pi);
        });
      }
    });

    //Gyroskop
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          gyroX = event.x;
          gyroY = event.y;
          gyroZ = event.z;
        });
      }
    });

    //Magnetometer
    _magnetometerSubscription = magnetometerEvents.listen((MagnetometerEvent event) {
      if (mounted) {
        setState(() {
          magX = event.x;
          magY = event.y;
          magZ = event.z;
        });
      }
    });
  }

  @override
  void dispose() {
    //Datenstreams beenden
    _accelerometerSubscription.cancel();
    _gyroscopeSubscription.cancel();
    _magnetometerSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensorenübersicht'),
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

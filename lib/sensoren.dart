import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

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
  double roll = 0.0; //nach vorne / zu einem kippen

  String _accelerometer_data = "";
  String _gyroscope_data = "";
  String _magnetometer_data = "";
  String _tilt_data = "";

  bool accel_on = true;
  bool gyro_on = true;
  bool magnet_on = true;
  bool tilt_on = true;

  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
  late StreamSubscription<MagnetometerEvent> _magnetometerSubscription;

  Future<void> _loadStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accelerometer_data =
          prefs.getString('accel_data') ?? "No Accelerometer Data Saved!";
      _gyroscope_data =
          prefs.getString('gyro_data') ?? "No Gyroscope Data Saved!";
      _magnetometer_data =
          prefs.getString('mag_data') ?? "No Magnetometer Data Saved!";
      _tilt_data = prefs.getString('tilt_data') ?? "No Tilt Data Saved!";
    });
  }

  Future<void> _writeStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String accelString =
          "Accelerator X: ${accelX.toStringAsFixed(2)}, Y: ${accelY.toStringAsFixed(2)}, Z: ${accelZ.toStringAsFixed(2)},";
      String gyroString =
          "Gyroscope X: ${gyroX.toStringAsFixed(2)}, Y: ${gyroY.toStringAsFixed(2)}, Z: ${gyroZ.toStringAsFixed(2)},";
      String magnetString =
          "Magnetometer X: ${magX.toStringAsFixed(2)}, Y: ${magY.toStringAsFixed(2)}, Z: ${magZ.toStringAsFixed(2)},";
      String tiltString =
          "Pitch: ${pitch.toStringAsFixed(2)}, Roll: ${roll.toStringAsFixed(2)}";
      prefs.setString('accel_data', accelString);
      prefs.setString('gyro_data', gyroString);
      prefs.setString('mag_data', magnetString);
      prefs.setString('tilt_data', tiltString);

      _loadStorage(); // update displayed data
    });
  }

  Future<void> _overwriteStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('accel_data', "-");
      prefs.setString('gyro_data', "-");
      prefs.setString('mag_data', "-");
      prefs.setString('tilt_data', "-");

      _loadStorage(); // update displayed data
    });
  }

  @override
  void initState() {
    super.initState();
    _loadStorage();

    //Init verschiedene Sensoren
    //Acceleromenter
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          accelX = event.x;
          accelY = event.y;
          accelZ = event.z;

          //Gelesene Neigungen umrechnen
          pitch = atan2(event.y, sqrt(event.x * event.x + event.z * event.z)) *
              (180 / pi);
          roll = atan2(event.x, sqrt(event.y * event.y + event.z * event.z)) *
              (180 / pi);
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
    _magnetometerSubscription =
        magnetometerEvents.listen((MagnetometerEvent event) {
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
              Switch(
                  // This bool value toggles the switch.
                  value: accel_on,
                  activeColor: Colors.green,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      accel_on = value;
                    });

                    if (accel_on) {
                      _accelerometerSubscription = accelerometerEvents
                          .listen((AccelerometerEvent event) {
                        if (mounted) {
                          setState(() {
                            accelX = event.x;
                            accelY = event.y;
                            accelZ = event.z;

                            //Gelesene Neigungen umrechnen
                            pitch = atan2(
                                    event.y,
                                    sqrt(event.x * event.x +
                                        event.z * event.z)) *
                                (180 / pi);
                            roll = atan2(
                                    event.x,
                                    sqrt(event.y * event.y +
                                        event.z * event.z)) *
                                (180 / pi);
                          });
                        }
                      });
                    } else {
                      _accelerometerSubscription.cancel();
                      accelX = 0.0;
                      accelY = 0.0;
                      accelZ = 0.0;
                      pitch = 0.0; //Lenkradneigung
                      roll = 0.0; //nach vorne / zu einem kippen
                    }
                  }),
              Text('X: ${accelX.toStringAsFixed(2)}'),
              Text('Y: ${accelY.toStringAsFixed(2)}'),
              Text('Z: ${accelZ.toStringAsFixed(2)}'),
              Text('Nickwinkel (Pitch): ${pitch.toStringAsFixed(2)}°'),
              Text('Rollwinkel (Roll): ${roll.toStringAsFixed(2)}°'),
              const SizedBox(height: 20),
              const Text(
                'Gyroskop (Gyroscope)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Switch(
                  // This bool value toggles the switch.
                  value: gyro_on,
                  activeColor: Colors.green,
                  onChanged: (bool value) {
                    setState(() {
                      gyro_on = value;
                    });
                    // This is called when the user toggles the switch.
                    if (gyro_on) {
                      _gyroscopeSubscription =
                          gyroscopeEvents.listen((GyroscopeEvent event) {
                        if (mounted) {
                          setState(() {
                            gyroX = event.x;
                            gyroY = event.y;
                            gyroZ = event.z;
                          });
                        }
                      });
                    } else {
                      _gyroscopeSubscription.cancel();

                      gyroX = 0.0;
                      gyroY = 0.0;
                      gyroZ = 0.0;
                    }
                  }),
              Text('X: ${gyroX.toStringAsFixed(2)}'),
              Text('Y: ${gyroY.toStringAsFixed(2)}'),
              Text('Z: ${gyroZ.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              const Text(
                'Magnetometer',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Switch(
                  // This bool value toggles the switch.
                  value: magnet_on,
                  activeColor: Colors.green,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      magnet_on = value;
                    });

                    if (magnet_on) {
                      _magnetometerSubscription =
                          magnetometerEvents.listen((MagnetometerEvent event) {
                        if (mounted) {
                          setState(() {
                            magX = event.x;
                            magY = event.y;
                            magZ = event.z;
                          });
                        }
                      });
                    } else {
                      _magnetometerSubscription.cancel();

                      magX = 0.0;
                      magY = 0.0;
                      magZ = 0.0;
                    }
                  }),
              Text('X: ${magX.toStringAsFixed(2)}'),
              Text('Y: ${magY.toStringAsFixed(2)}'),
              Text('Z: ${magZ.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              Text(
                'zuletzt gespeicherte Sensordaten',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '$_accelerometer_data',
              ),
              Text(
                '$_tilt_data',
              ),
              Text(
                '$_gyroscope_data',
              ),
              Text(
                '$_magnetometer_data',
              ),
              TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.blueAccent),
                    foregroundColor:
                        MaterialStatePropertyAll<Color>(Color(0xffffffff))),
                onPressed: _writeStorage,
                child: Text("Daten Speichern"),
              ),
              TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.redAccent),
                    foregroundColor:
                        MaterialStatePropertyAll<Color>(Color(0xffffffff))),
                onPressed: _overwriteStorage,
                child: Text("Daten Löschen"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

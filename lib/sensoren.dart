import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  //Fuer das Diagramm
  List<double> accelXData = [];
  List<double> accelYData = [];
  List<double> accelZData = [];

  String _accelerometer_data = "";
  String _gyroscope_data = "";
  String _magnetometer_data = "";
  String _tilt_data = "";

  bool accel_on = true;
  bool gyro_on = true;
  bool magnet_on = true;
  bool tilt_on = true;

  // **Neue Variablen zur Frequenzsteuerung**
  double accelFrequency = 50.0; // Start-Frequenz in Hz für Accelerometer
  double gyroFrequency = 50.0;  // Start-Frequenz in Hz für Gyroskop
  double magnetFrequency = 50.0; // Start-Frequenz in Hz für Magnetometer

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

          //Diagramm
        if (accelXData.length > 20) accelXData.removeAt(0); // Limit auf 20 Punkte
        if (accelYData.length > 20) accelYData.removeAt(0);
        if (accelZData.length > 20) accelZData.removeAt(0);

        accelXData.add(accelX);
        accelYData.add(accelY);
        accelZData.add(accelZ);
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

   //Methode zur Frequenzaktualisierung
  void _updateFrequency(StreamSubscription sensorSubscription, double frequency, Function startSubscription) {
    sensorSubscription.cancel();
    Future.delayed(Duration(milliseconds: (1000 / frequency).round()), startSubscription as FutureOr Function()?);
  }

   void _startAccelerometerSubscription() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted && accel_on) {
        setState(() {
          accelX = event.x;
          accelY = event.y;
          accelZ = event.z;

          pitch = atan2(event.y, sqrt(event.x * event.x + event.z * event.z)) * (180 / pi);
          roll = atan2(event.x, sqrt(event.y * event.y + event.z * event.z)) * (180 / pi);

          if (accelXData.length > 20) accelXData.removeAt(0); // Limit auf 20 Punkte
          if (accelYData.length > 20) accelYData.removeAt(0);
          if (accelZData.length > 20) accelZData.removeAt(0);

          accelXData.add(accelX);
          accelYData.add(accelY);
          accelZData.add(accelZ);
        });
      }
    });
  }

   void _startGyroscopeSubscription() {
    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      if (mounted && gyro_on) {
        setState(() {
          gyroX = event.x;
          gyroY = event.y;
          gyroZ = event.z;
        });
      }
    });
  }

  void _startMagnetometerSubscription() {
    _magnetometerSubscription = magnetometerEvents.listen((MagnetometerEvent event) {
      if (mounted && magnet_on) {
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
              //GUI Element zur Frequenanpassung des Beschleunigungssensors
              Text('Accelerometer Frequenz: ${accelFrequency.toStringAsFixed(0)} Hz'),
              SizedBox(
                width: 200,
                child:
              Slider(
                min: 1.0,
                max: 100.0,
                value: accelFrequency,
                divisions: 99,
                label: accelFrequency.toStringAsFixed(0),
                onChanged: (value) {
                  setState(() {
                    accelFrequency = value;
                  });
                },
              )
              ),
              ElevatedButton(
                onPressed: () => _updateFrequency(_gyroscopeSubscription, gyroFrequency, _startGyroscopeSubscription),
                child: const Text('Accelerometer Frequenz aktualisieren'),
              ),
              Switch(
                  // This bool value toggles the switch.q
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
                'Gyroskop',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
               //GUI-Element zur Frequenzanpassung des Gyroskops*
              Text('Gyroscope Frequenz: ${gyroFrequency.toStringAsFixed(0)} Hz'),
              SizedBox(
                width: 200,
                child: 
                Slider(
                min: 1.0,
                max: 100.0,
                value: gyroFrequency,
                divisions: 99,
                label: gyroFrequency.toStringAsFixed(0),
                onChanged: (value) {
                  setState(() {
                    gyroFrequency = value;
                  });
                },
              ),
              ),
              
              ElevatedButton(
                onPressed: () => _updateFrequency(_gyroscopeSubscription, gyroFrequency, _startGyroscopeSubscription),
                child: const Text('Gyroskopfrequenz aktualisieren'),
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
              //GUI-Element zur Frequenzanpassung des Magnetometers**
              Text('Magnetometer Frequenz: ${magnetFrequency.toStringAsFixed(0)} Hz'),
              SizedBox(
                width: 200,
                child:
              Slider(
                min: 1.0,
                max: 100.0,
                value: magnetFrequency,
                divisions: 99,
                label: magnetFrequency.toStringAsFixed(0),
                onChanged: (value) {
                  setState(() {
                    magnetFrequency = value;
                  });
                },
              )
              ),
              ElevatedButton(
                onPressed: () => _updateFrequency(_magnetometerSubscription, magnetFrequency, _startMagnetometerSubscription),
                child: const Text('Magnetometerfrequenz aktualisieren'),
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
                            const Text(
                'Beschleunigungssensor (Accelerometer)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
               // Container für das Diagramm
              Container(
                height: 200,
                padding: const EdgeInsets.all(16.0),
                child: SfCartesianChart(
                  primaryXAxis: NumericAxis(),
                  primaryYAxis: NumericAxis(),
series: <LineSeries<double, int>>[
  // Serie für die X-Achse des Accelerometers (Rot)
  LineSeries<double, int>(
    dataSource: accelXData,
    xValueMapper: (_, index) => index,
    yValueMapper: (double value, _) => value,
    color: Colors.red, // X-Achse in Rot
    name: 'Accel X',
  ),
  // Serie für die Y-Achse des Accelerometers (Grün)
  LineSeries<double, int>(
    dataSource: accelYData,
    xValueMapper: (_, index) => index,
    yValueMapper: (double value, _) => value,
    color: Colors.green, // Y-Achse in Grün
    name: 'Accel Y',
  ),
  // Serie für die Z-Achse des Accelerometers (Blau)
  LineSeries<double, int>(
    dataSource: accelZData,
    xValueMapper: (_, index) => index,
    yValueMapper: (double value, _) => value,
    color: Colors.blue, // Z-Achse in Blau
    name: 'Accel Z',
                ),
              ],
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ignore_for_file: deprecated_member_use, non_constant_identifier_names, library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
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

  int _samplingInterval = 1000;
  Timer? _updateTimer;

  // Daten für Pitch and Roll für das Chart
  final List<ChartData> _chartData = [];
  final int _chartDataLimit = 100;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _loadStorage();
    _initSensorListeners();
    _startUpdatingSensorData();
  }

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

      _loadStorage();
    });
  }

  Future<void> _overwriteStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('accel_data', "-");
      prefs.setString('gyro_data', "-");
      prefs.setString('mag_data', "-");
      prefs.setString('tilt_data', "-");

      _loadStorage();
    });
  }

  void _initSensorListeners() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted && accel_on) {
        accelX = event.x;
        accelY = event.y;
        accelZ = event.z;

        _calculatePitchAndRoll();
      }
    });

    _gyroscopeSubscription = gyroscopeEvents.listen((GyroscopeEvent event) {
      if (mounted && gyro_on) {
        gyroX = event.x;
        gyroY = event.y;
        gyroZ = event.z;
      }
    });

    _magnetometerSubscription =
        magnetometerEvents.listen((MagnetometerEvent event) {
      if (mounted && magnet_on) {
        magX = event.x;
        magY = event.y;
        magZ = event.z;
      }
    });
  }

  void _calculatePitchAndRoll() {
    pitch = atan2(accelY, sqrt(accelX * accelX + accelZ * accelZ)) * (180 / pi);
    roll = atan2(accelX, sqrt(accelY * accelY + accelZ * accelZ)) * (180 / pi);

    // Update Chart
    _updateChartData(pitch, roll);
  }

  void _startUpdatingSensorData() {
    _updateTimer?.cancel();
    _updateTimer =
        Timer.periodic(Duration(milliseconds: _samplingInterval), (timer) {
      if (mounted) {
        _time += _samplingInterval / 1000;
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  void _updateChartData(double pitch, double roll) {
    //Max Länge des Charts
    if (_chartData.length >= _chartDataLimit) {
      _chartData.removeAt(0);
    }
    //neu anhängen
    _chartData.add(ChartData(_time, pitch, roll));
  }

  @override
  void dispose() {
    //Datenstreams beenden
    _accelerometerSubscription.cancel();
    _gyroscopeSubscription.cancel();
    _magnetometerSubscription.cancel();
    _updateTimer?.cancel();
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
              DropdownButton<int>(
                value: _samplingInterval,
                items: const [
                  DropdownMenuItem(value: 100, child: Text('0.1 Sekunden')),
                  DropdownMenuItem(value: 1000, child: Text('1 Sekunde')),
                  DropdownMenuItem(value: 2000, child: Text('2 Sekunden')),
                ],
                onChanged: (int? value) {
                  setState(() {
                    _samplingInterval = value!;
                    _startUpdatingSensorData(); // Restart, wenn neue Sensorfrequenz eingegeben
                  });
                },
              ),
              const Text(
                'Beschleunigungssensor (Accelerometer)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: accel_on,
                activeColor: Colors.green,
                onChanged: (bool value) {
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

                          _calculatePitchAndRoll();
                        });
                      }
                    });
                  } else {
                    _accelerometerSubscription.cancel();
                    accelX = 0.0;
                    accelY = 0.0;
                    accelZ = 0.0;
                  }
                }),
              Text('X: ${accelX.toStringAsFixed(2)}'),
              Text('Y: ${accelY.toStringAsFixed(2)}'),
              Text('Z: ${accelZ.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              const Text(
                'Gyroskop',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: gyro_on,
                activeColor: Colors.green,
                onChanged: (bool value) {
                  setState(() {
                    gyro_on = value;
                  });
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
                value: magnet_on,
                activeColor: Colors.green,
                onChanged: (bool value) {
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
              const Text(
                'zuletzt gespeicherte Sensordaten',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(_accelerometer_data),
              Text(_tilt_data),
              Text(_gyroscope_data),
              Text(_magnetometer_data),
              TextButton(
                style: const ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Colors.blueAccent),
                    foregroundColor:
                        MaterialStatePropertyAll<Color>(Color(0xffffffff))),
                onPressed: _writeStorage,
                child: const Text("Daten Speichern"),
              ),
              TextButton(
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.redAccent),
                    foregroundColor:
                        MaterialStatePropertyAll<Color>(Color(0xffffffff))),
                onPressed: _overwriteStorage,
                child: const Text("Daten Löschen"),
              ),
              const SizedBox(height: 20),
              // Chart fürs Neigen
              SizedBox(
                height: 300,
                child: SfCartesianChart(
                  title: ChartTitle(text: 'Pitch und Roll Werte'),
                  legend: Legend(isVisible: true),
                  primaryXAxis: NumericAxis(
                    title: AxisTitle(text: 'Zeit (s)'),
                    minimum:
                        _time > 20 ? _time - 20 : 0, // Dynamische x anzeige auf 20 sekunden
                    maximum: _time,
                    interval:
                        1, //Abstand auf der x achse
                  ),
                  primaryYAxis:
                      NumericAxis(title: AxisTitle(text: 'Winkel (°)')),
                  series: <ChartSeries>[
                    LineSeries<ChartData, double>(
                      name: 'Pitch',
                      dataSource: _chartData,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.pitch,
                      markerSettings: const MarkerSettings(isVisible: true),
                    ),
                    LineSeries<ChartData, double>(
                      name: 'Roll',
                      dataSource: _chartData,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.roll,
                      markerSettings: const MarkerSettings(isVisible: true),
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

// Data class for chart
class ChartData {
  final double x; // Zeit in Sek.
  final double pitch;
  final double roll;

  ChartData(this.x, this.pitch, this.roll);
}

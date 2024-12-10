import 'package:flutter/material.dart';
import 'location_service.dart';
import 'package:location/location.dart';

class LocationApp extends StatefulWidget {
  @override
  _LocationAppState createState() => _LocationAppState();
}

class _LocationAppState extends State<LocationApp> {
  String _locationInfo = "Noch keine Daten abgerufen";
  final LocationService _locationService = LocationService();

  Future<void> _getLocations() async {
    bool hasPermission = await _locationService.checkPermissions();
    if (!hasPermission) {
      setState(() {
        _locationInfo = "Berechtigungen oder Standortdienste fehlen.";
      });
      return;
    }

    String result = "";

    try {
      LocationData? highAccuracy = await _locationService.getLocation(LocationAccuracy.high);
      if (highAccuracy != null) {
        result += "High Accuracy:\n"
            "Lat: ${highAccuracy.latitude}, Lon: ${highAccuracy.longitude}, Accuracy: ${highAccuracy.accuracy}m\n";
      }

      // await Future.delayed(Duration(seconds: 2));

      LocationData? mediumAccuracy = await _locationService.getLocation(LocationAccuracy.balanced);
      if (mediumAccuracy != null) {
        result += "Medium Accuracy:\n"
            "Lat: ${mediumAccuracy.latitude}, Lon: ${mediumAccuracy.longitude}, Accuracy: ${mediumAccuracy.accuracy}m\n";
      }

      // await Future.delayed(Duration(seconds: 2));

      LocationData? lowAccuracy = await _locationService.getLocation(LocationAccuracy.low);
      if (lowAccuracy != null) {
        result += "Low Accuracy:\n"
            "Lat: ${lowAccuracy.latitude}, Lon: ${lowAccuracy.longitude}, Accuracy: ${lowAccuracy.accuracy}m\n";
      }
    } catch (e) {
      result = "Fehler beim Abrufen der Position: $e";
    }

    setState(() {
      _locationInfo = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _locationInfo,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getLocations,
              child: Text("Standorte mit Genauigkeiten testen"),
            ),
          ],
        ),
      ),
    );
  }
}

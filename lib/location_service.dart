import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  // Methode, um Berechtigungen abzufragen
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  Future<LocationData?> getLocation(LocationAccuracy accuracy) async {
    try {
      _location.changeSettings(accuracy: accuracy);
      return await _location.getLocation();
    } catch (e) {
      print("Fehler Positionsabruf: $e");
      return null;
    }
  }
}

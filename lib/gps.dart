import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GpsPage extends StatefulWidget {
  const GpsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GpsPageState createState() => _GpsPageState();
}

class _GpsPageState extends State<GpsPage> {
  //Liste für gespeicherten Positionen
  List<LatLng> _savedPositions = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadSavedPositions();
  }

  List<LatLng> hardcodedRoute = [
    LatLng(51.448012847547375, 7.270595761134885),
    LatLng(51.44705592367576, 7.26771353140143),
    LatLng(51.44619271272524, 7.268263146561089),
    LatLng(51.44511025056258, 7.265097363317558),
    LatLng(51.44419551359768, 7.262285408755903),
    LatLng(51.443331828986615, 7.263037989043566),
    LatLng(51.443011665886154, 7.26312160907553),
    LatLng(51.442757454671685, 7.262379331292123),
    LatLng(51.44264972003007, 7.2618247985997755),
    LatLng(51.443056367671204, 7.261458130615873),
    LatLng(51.44372055195047, 7.260958138979937),
    LatLng(51.44372850409007, 7.2611495160850845),
  ];

  Future<void> _loadSavedPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final positions = prefs.getStringList('savedPositions') ?? [];
    setState(() {
      _savedPositions = positions.map((position) {
        final coords = position.split(',');
        return LatLng(double.parse(coords[0]), double.parse(coords[1]));
      }).toList();
    });

    //Zoom auf die letzte Position, wenn in savedPositions vorhanden
    if (_savedPositions.isNotEmpty) {
      _mapController.move(_savedPositions.last, 15);
    }
  }

  Future<void> _savePosition(LatLng position) async {
    final prefs = await SharedPreferences.getInstance();
    //Remove Position, so das nur eine max. Anzahl gespeichert wird.
    if (_savedPositions.length >= 2) {
      _savedPositions.removeAt(0);
    }
    _savedPositions.add(position);
    await prefs.setStringList('savedPositions',
        _savedPositions.map((p) => '${p.latitude},${p.longitude}').toList());
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Standortdienste sind deaktiviert.")),
        );
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Standortberechtigung verweigert.")),
          );
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Standortberechtigung dauerhaft verweigert.")),
        );
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentPosition = LatLng(position.latitude, position.longitude);

    //save neuer Position
    _savePosition(currentPosition);
    setState(() {
      _mapController.move(currentPosition, 15);
    });
  }

  Future<void> _getNetworkLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Standortdienste sind deaktiviert.")),
        );
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Standortberechtigung verweigert.")),
          );
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Standortberechtigung dauerhaft verweigert.")),
        );
      });
      return;
    }

    //Netzwerk
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    LatLng networkPosition = LatLng(position.latitude, position.longitude);

    //save neuer Position
    _savePosition(networkPosition);
    setState(() {
      _mapController.move(networkPosition, 15);
    });
  }

// Alle Positionen löschen
  Future<void> _clearSavedPositions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPositions.clear();
    });
    await prefs.remove('savedPositions');
  }

  //Leichte Verschiebung, um Überlappung zu verhindern
  LatLng _adjustMarkerPosition(LatLng originalPosition, int index) {
    double offset = 0.0001 * (index + 1);
    return LatLng(originalPosition.latitude + offset,
        originalPosition.longitude + offset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Standortbestimmung"),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center:
              _savedPositions.isNotEmpty ? _savedPositions.last : LatLng(0, 0),
          zoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _savedPositions
                .asMap()
                .map((index, position) {
                  Color markerColor = index == 0 ? Colors.red : Colors.blue;
                  return MapEntry(
                    index,
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: _adjustMarkerPosition(position, index),
                      builder: (ctx) =>
                          Icon(Icons.location_on, color: markerColor, size: 40),
                    ),
                  );
                })
                .values
                .toList(),
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                strokeWidth: 3,
                points: hardcodedRoute,
                color: Color.fromARGB(255, 244, 54, 57),
              ),
            ],
          ),
          MarkerLayer(
            markers: hardcodedRoute.map((coords) {
              return Marker(
                point: coords,
                builder: (ctx) =>
                    Icon(Icons.circle, color: Colors.red, size: 10),
              );
            }).toList(),
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            tooltip: 'GPS-Position ermitteln',
            child: const Icon(Icons.location_on),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _getNetworkLocation,
            tooltip: 'Netzwerk-Position ermitteln',
            child: const Icon(Icons.wifi_tethering),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _clearSavedPositions,
            tooltip: 'Alle Positionen löschen',
            child: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }
}

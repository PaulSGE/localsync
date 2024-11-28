import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GpsPage extends StatefulWidget {
  const GpsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GpsPageState createState() => _GpsPageState();
}

class _GpsPageState extends State<GpsPage> {
  //Liste für gespeicherten Positionen
  List<Map<String, dynamic>> _manSavedPositionshigh = [];
  List<Map<String, dynamic>> _autoSavedPositionshigh = [];

  //List<Map<String, dynamic>> _manSavedPositionsmedium = [];
  //List<Map<String, dynamic>> _autoSavedPositionsmedium = [];

  List<Map<String, dynamic>> _manSavedPositionsgps = [];
  List<Map<String, dynamic>> _autoSavedPositionsgps = [];

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // _loadSavedPositions();
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

  void _exportData() async {
    String jsonManuallyCapturedhigh = jsonEncode(_manSavedPositionshigh);
    //String jsonManuallyCapturedmedium = jsonEncode(_manSavedPositionsmedium);
    String jsonManuallyCapturedgps = jsonEncode(_manSavedPositionsgps);
    String jsonAutoCapturedhigh = jsonEncode(_autoSavedPositionshigh);
    //String jsonAutoCapturedmedium = jsonEncode(_autoSavedPositionsmedium);
    String jsonAutoCapturedgps = jsonEncode(_autoSavedPositionsgps);
    String jsonHardcodeRoute = jsonEncode(hardcodedRoute);

    var url = Uri.http("${dotenv.env['SERVER']}:${dotenv.env['PORT']}");

    Map<String, dynamic> requestBody = {
      "manuallyCapturedhigh": jsonManuallyCapturedhigh,
      "autoCapturedhigh": jsonAutoCapturedhigh,
      //"manuallyCapturedmedium": jsonManuallyCapturedmedium,
      //"autoCapturedmedium": jsonAutoCapturedmedium,
      "manuallyCapturedgps": jsonManuallyCapturedgps,
      "autoCapturedgps": jsonAutoCapturedgps,
      "hardCodedRouteh": jsonHardcodeRoute,
    };

    try {
      await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(requestBody),
      );
    } catch (e) {
      print("Exception aufgetreten: $e");
    }
  }

  // Future<void> _loadSavedPositions() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final positions = prefs.getStringList('manSavedPositions') ?? [];
  //   setState(() {
  //     _manSavedPositions = positions.map((position) {
  //       final coords = position.split(',');
  //       return LatLng(double.parse(coords[0]), double.parse(coords[1]));
  //     }).toList();
  //   });

  //   //Zoom auf die letzte Position, wenn in savedPositions vorhanden
  //   // if (_manSavedPositions.isNotEmpty) {
  //   //   _mapController.move(_manSavedPositions.last, 15);
  //   // }
  // }

  Future<void> _saveManualPosition(LatLng position, int art) async {
    Map<String, dynamic> newEntry = {
      'position': {
        'latitude': position.latitude,
        'longitude': position.longitude
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
    if(art == 1){
      _manSavedPositionshigh.add(newEntry);
    }else if(art == 2){
      //_manSavedPositionsmedium.add(newEntry);
    }else if(art == 3){
      _manSavedPositionsgps.add(newEntry);
    }
  }

  var _autoCapture = false;
  Timer? timer;

  void _toggleAutoLocationCapture() {
    setState(() {
      _autoCapture = !_autoCapture;
    });

    if (!_autoCapture) {
      timer!.cancel();
      return;
    }

    timer = Timer.periodic(
        Duration(seconds: 5), (Timer t) => _automaticallyGetCurrentLocation());
  }

  Future<void> _saveAutoPosition(LatLng position,int art) async {
    Map<String, dynamic> newEntry = {
      'position': {
        'latitude': position.latitude,
        'longitude': position.longitude
      },
      'timestamp': DateTime.now().toString()
    };
    if(art == 1){
      _autoSavedPositionshigh.add(newEntry);
    }else if(art == 2){
      //_autoSavedPositionsmedium.add(newEntry);
    }else if(art == 3){
      _autoSavedPositionsgps.add(newEntry);
    }
  }

  Future<void> _manuallyGetCurrentLocation() async {
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

    Position positionhigh = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, forceAndroidLocationManager: true,
        );
    LatLng currentPositionhigh = LatLng(positionhigh.latitude, positionhigh.longitude);

    // Position positionmedium = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.medium, forceAndroidLocationManager: true,
    //     );
    // LatLng currentPositionmedium = LatLng(positionmedium.latitude, positionmedium.longitude);

    Position positiongps = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
  forceAndroidLocationManager: true,// GPS-Provider erzwingen
);
    LatLng currentPositiongps = LatLng(positiongps.latitude, positiongps.longitude);

    //ENTKOMMENTIEREN FÜR NETZWERKPOSITIONIERUNG
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.low);

    //save neuer Position
    _saveManualPosition(currentPositionhigh,1);
    //_saveManualPosition(currentPositionmedium,2);
    _saveManualPosition(currentPositiongps,3);

    setState(() {
      _mapController.move(currentPositionhigh, 15);
    });
  }

  Future<void> _automaticallyGetCurrentLocation() async {
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

     Position positionhigh = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentPositionhigh = LatLng(positionhigh.latitude, positionhigh.longitude);

    // Position positionmedium = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.medium);
    // LatLng currentPositionmedium = LatLng(positionmedium.latitude, positionmedium.longitude);

    Position positiongps = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        forceAndroidLocationManager: true,
  );
    LatLng currentPositiongps = LatLng(positiongps.latitude, positiongps.longitude);

    //ENTKOMMENTIEREN FÜR NETZWERKPOSITIONIERUNG
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.low);

    //save neuer Position
    _saveAutoPosition(currentPositionhigh,1);
    //_saveAutoPosition(currentPositionmedium,2);
    _saveAutoPosition(currentPositiongps,3);
  }

// Alle Positionen löschen
  Future<void> _clearSavedPositions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _manSavedPositionsgps.clear();
      //_manSavedPositionsmedium.clear();
      _manSavedPositionshigh.clear();
      _autoSavedPositionsgps.clear();
      //_autoSavedPositionsmedium.clear();
      _autoSavedPositionshigh.clear();
    });
    await prefs.remove('autoSavedPositions');
    await prefs.remove('manSavedPositions');
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
          center: LatLng(
              51.44750116717069, 7.271411812287161), // Hochschule Location
          zoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: hardcodedRoute,
                color: Colors.red,
                strokeWidth: 6,
              ),
            ],
          ),
          MarkerLayer(
              // MARKER LAYER MANUELLE POSITIONEN
              markers: _manSavedPositionsgps
                  .asMap()
                  .map((index, entry) {
                    LatLng location = LatLng(entry['position']['latitude'],
                        entry['position']['longitude']);

                    return MapEntry(
                      index,
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: location,
                        builder: (ctx) => Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                    );
                  })
                  .values
                  .toList()),
          MarkerLayer(
              // MARKER LAYER AUTOMATISCH ERFASSTE POSITIONEN
              markers: _autoSavedPositionsgps
                  .asMap()
                  .map((index, entry) {
                    LatLng location = LatLng(entry['position']['latitude'],
                        entry['position']['longitude']);

                    return MapEntry(
                      index,
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: location,
                        builder: (ctx) => Icon(
                          Icons.location_pin,
                          color: Colors.blue,
                          size: 10,
                        ),
                      ),
                    );
                  })
                  .values
                  .toList()),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _manuallyGetCurrentLocation,
            tooltip: 'GPS-Position ermitteln',
            child: const Icon(Icons.location_on),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _toggleAutoLocationCapture,
            tooltip: 'Automatische Erfassung Togglen',
            child: Icon(
              _autoCapture ? Icons.pause : Icons.play_arrow,
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _exportData,
            tooltip: 'Export Data',
            child: const Icon(Icons.save),
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

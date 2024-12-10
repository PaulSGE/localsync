import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _coordinateController = TextEditingController();
  LatLng? _newPoint;

  final List url = ['http://85.215.67.153:3001/py'];

  // Route 1: Eine Liste von Punkten (LatLng)
  final List<LatLng> route1 = [
    LatLng(51.480203822002565, 7.202850328508449),
    LatLng(51.48076764667677, 7.202435007770543),
    LatLng(51.48088930512144, 7.201738155388343),
    LatLng(51.48133883841012, 7.201465777417864),
    LatLng(51.482144504413775, 7.200705672638127),
    LatLng(51.4828905852812, 7.200918315327095),
    LatLng(51.481571400881414, 7.199891664423626),
    LatLng(51.481080479995775, 7.200575895857488),
    LatLng(51.480880414127476, 7.201473219598438),
    LatLng(51.48054035835537, 7.201366227168291),
    LatLng(51.48033582995885, 7.2005309121852115),
    LatLng(51.479863180221066, 7.198481393416557),
    LatLng(51.47956371014744, 7.198946257135974),
    LatLng(51.4799782064199, 7.200765998275842),
    LatLng(51.48027861195343, 7.202084777871267)
  ];

  // Route 2: Eine andere Liste von Punkten (LatLng)
  final List<LatLng> route2 = [
    LatLng(51.48200485821175, 7.216148843149383),
    LatLng(51.48204319662747, 7.216678718211532),
    LatLng(51.48209191756133, 7.217137571796989),
    LatLng(51.48250517188795, 7.217218411866542),
    LatLng(51.482458120861814, 7.217657570045277),
    LatLng(51.48213668960578, 7.21802738591002),
    LatLng(51.48136966956355, 7.218356479317629),
    LatLng(51.48093039523358, 7.218513990168929),
    LatLng(51.48078695941613, 7.21727660165772),
    LatLng(51.48105416276181, 7.217162039327305)
  ];

  final List<LatLng> highpoints = [
    LatLng(51.4814085, 7.2052173),
    LatLng(51.4802119, 7.2029687),
    LatLng(51.4807671, 7.2024472),
    LatLng(51.4809144, 7.2016653),
    LatLng(51.4812272, 7.2014786),
    LatLng(51.4821797, 7.2008703),
    LatLng(51.4828809, 7.2011395),
    LatLng(51.48156, 7.2001502),
    LatLng(51.4810599, 7.200564),
    LatLng(51.4809319, 7.2014866),
    LatLng(51.4806924, 7.2014409),
    LatLng(51.4809222, 7.1977905),
    LatLng(51.4798618, 7.1984394),
    LatLng(51.4795498, 7.2005655),
    LatLng(51.4798618, 7.2006328),
    LatLng(51.48212, 7.2162991),
    LatLng(51.4820497, 7.2166816),
    LatLng(51.4820718, 7.2170893),
    LatLng(51.4823908, 7.2172411),
    LatLng(51.4823467, 7.2176645),
    LatLng(51.4821965, 7.2180072),
    LatLng(51.4813567, 7.2181374),
    LatLng(51.4809117, 7.2185886),
    LatLng(51.4806998, 7.2174896),
    LatLng(51.4809391, 7.2172123)
  ];

  final List<LatLng> locamanager = [
    LatLng(51.4802137, 7.2029721),
    LatLng(51.4807575, 7.2024727),
    LatLng(51.4809292, 7.2019632),
    LatLng(51.481246, 7.2014715),
    LatLng(51.4821383, 7.2009166),
    LatLng(51.4828928, 7.2011293),
    LatLng(51.4815756, 7.2001612),
    LatLng(51.481064, 7.2005576),
    LatLng(51.4809322, 7.2014906),
    LatLng(51.4806765, 7.2014303),
    LatLng(51.4804065, 7.2006509),
    LatLng(51.4798581, 7.1984349),
    LatLng(51.4795198, 7.1990423),
    LatLng(51.4798538, 7.2006664),
    LatLng(51.4802636, 7.2021671),
    LatLng(51.4821283, 7.2162721),
    LatLng(51.4820434, 7.2166797),
    LatLng(51.4820758, 7.2170803),
    LatLng(51.4823721, 7.217181),
    LatLng(51.4823946, 7.2176403),
    LatLng(51.4821996, 7.218006),
    LatLng(51.4813546, 7.218143),
    LatLng(51.4809146, 7.2185872),
    LatLng(51.4807232, 7.2174462),
    LatLng(51.4809385, 7.2172059)
  ];

  final List<LatLng> lowpoints = [
    LatLng(51.4802042, 7.203258),
    LatLng(51.4802042, 7.203258),
    LatLng(51.4818347, 7.2008043),
    LatLng(51.4802042, 7.203258),
    LatLng(51.4802042, 7.203258),
    LatLng(51.4802042, 7.203258),
    LatLng(51.4802042, 7.203258),
    LatLng(51.4829046, 7.2048679),
    LatLng(51.4813904, 7.1973439),
    LatLng(51.4813904, 7.1973439),
    LatLng(51.4795862, 7.2007279),
    LatLng(51.48127, 7.1977532),
    LatLng(51.4779554, 7.2001049),
    LatLng(51.4795996, 7.2008051),
    LatLng(51.4795815, 7.2007154),

    LatLng(51.4819354, 7.2162626),
    LatLng(51.4819837, 7.2169166),
    LatLng(51.4819837, 7.2169166),
    LatLng(51.4829135, 7.2171591),
    LatLng(51.4823409, 7.2176634),
    LatLng(51.4821337, 7.2180563),
    LatLng(51.4813809, 7.2182078),
    LatLng(51.480935, 7.2186294),
    LatLng(51.4807319, 7.2171746),
    LatLng(51.4809921, 7.2172604)
  ];

  final List<LatLng> mediumpoints = [
    LatLng(51.4801878, 7.2029466),
    LatLng(51.480192, 7.2030773),
    LatLng(51.480192, 7.2030773),
    LatLng(51.480192, 7.2030773),
    LatLng(51.4830742, 7.2023457),
    LatLng(51.4830742, 7.2023457),
    LatLng(51.4816958, 7.1988686),
    LatLng(51.4817463, 7.1988329),
    LatLng(51.4817463, 7.1988329),
    LatLng(51.4817463, 7.1988329),
    LatLng(51.4795838, 7.2007252),
    LatLng(51.4795838, 7.2007252),
    LatLng(51.4794496, 7.1993057),
    LatLng(51.479595, 7.2007572),
    LatLng(51.479595, 7.2007572),

    LatLng(51.4819314, 7.2163109),
    LatLng(51.4818671, 7.2164938),
    LatLng(51.4818671, 7.2164938),
    LatLng(51.4825332, 7.2173361),
    LatLng(51.4823486, 7.2176652),
    LatLng(51.4821083, 7.2180218),
    LatLng(51.4813362, 7.2182098),
    LatLng(51.4808845, 7.2185562),
    LatLng(51.4805585, 7.2179414),
    LatLng(51.4809831, 7.2172915)
  ];

  @override
  void initState() {
    super.initState();
    _fetchCoordinatesFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routen'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(51.48100693389634, 7.208307568416578),
                    zoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: route1,
                          strokeWidth: 3.0,
                          color: Colors.grey,
                        ),
                        Polyline(
                          points: route2,
                          strokeWidth: 3.0,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        ...route1.map(
                          (point) => Marker(
                            point: point,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.black,
                              size: 20.0,
                            ),
                          ),
                        ),
                        ...route2.map(
                          (point) => Marker(
                            point: point,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.black,
                              size: 20.0,
                            ),
                          ),
                        ),
                        ...highpoints.map(
                          (point) => Marker(
                            point: point,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 20.0,
                            ),
                          ),
                        ),
                        ...locamanager.map(
                          (point) => Marker(
                            point: point,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.redAccent,
                              size: 20.0,
                            ),
                          ),
                        ),
                        ...mediumpoints.map(
                          (point) => Marker(
                            point: point,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.orange,
                              size: 20.0,
                            ),
                          ),
                        ),
                        ...lowpoints.map(
                          (point) => Marker(
                            point: point,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 20.0,
                            ),
                          ),
                        ),
                        if (_newPoint != null)
                          Marker(
                            point: _newPoint!,
                            builder: (ctx) => const Icon(
                              Icons.location_searching,
                              color: Colors.purple,
                              size: 30.0,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.black, size: 16),
                      SizedBox(width: 8),
                      Text('Groundtruth', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text('FLP High', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text('FLP Medium', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Text('FLP Low', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.redAccent, size: 16),
                      SizedBox(width: 8),
                      Text('Locationmanager', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_searching,
                          color: Colors.purple, size: 16),
                      SizedBox(width: 8),
                      Text('Eingabe', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Methode zum Hinzufügen eines neuen Punkts basierend auf der Eingabe
  void _addNewPoint() {
    final input = _coordinateController.text;
    final parts = input.split(',');

    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lon = double.tryParse(parts[1].trim());

      if (lat != null && lon != null) {
        setState(() {
          _newPoint = LatLng(lat, lon); // Den neuen Punkt setzen
        });
      } else {
        _showErrorDialog('Ungültige Koordinaten');
      }
    } else {
      _showErrorDialog('Bitte gib Koordinaten im Format lat, lon ein');
    }
  }

  // Methode zum Anzeigen einer Fehlermeldung
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fehler'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchCoordinatesFromAPI() async {
    try {
      final response = await http.get(Uri.parse(url[0]));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lat = data['lat'];
        final lon = data['long'];

        if (lat != null && lon != null) {
          setState(() {
            _newPoint = LatLng(lat, lon);
          });
        } else {
          _showErrorDialog('Ungültige Koordinaten erhalten');
        }
      } else {
        print("ok");
      }
    } catch (e) {
      _showErrorDialog('Fehler: $e');
    }
  }
}

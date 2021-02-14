import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String url =
          'https://api.mapbox.com/styles/v1/mahmoudsalah37/ckl3gwgc32e7r17tf1ozf3nyl/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibWFobW91ZHNhbGFoMzciLCJhIjoiY2tsM2drZ2dyMDRjczJubjFjdjNvd2FyYyJ9.DO6kIrBbhYG4-HxrhWPsmA',
      id = 'mapbox.mapbox-streets-v8',
      accessToken =
          'pk.eyJ1IjoibWFobW91ZHNhbGFoMzciLCJhIjoiY2tsM2drZ2dyMDRjczJubjFjdjNvd2FyYyJ9.DO6kIrBbhYG4-HxrhWPsmA';
  final key = GlobalKey<ScaffoldState>();
  final points = [
    LatLng(35.22, -101.83),
    LatLng(30.10, -100.79),
    LatLng(33.10, -99.79),
    LatLng(35.22, -101.83),
  ];

  LatLng point = LatLng(0.0, 0.0);

  bool _checkIfValidMarker(LatLng tap, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int j = 0; j < vertices.length - 1; j++) {
      if (rayCastIntersect(tap, vertices[j], vertices[j + 1])) {
        intersectCount++;
      }
    }

    return ((intersectCount % 2) == 1); // odd = inside, even = outside;
  }

  bool rayCastIntersect(LatLng tap, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = tap.latitude;
    double pX = tap.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false; // a and b can't both be above or below pt.y, and a or
      // b must be east of pt.x
    }

    double m = (aY - bY) / (aX - bX); // Rise over run
    double bee = (-aX) * m + aY; // y = mx + b
    double x = (pY - bee) / m; // algebra is neat!

    return x > pX;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(),
      body: Container(
        child: FlutterMap(
          options: MapOptions(
            onTap: (v) {
              setState(() {
                point = LatLng(v.latitude, v.longitude);
                final isInside = _checkIfValidMarker(point, points);
                key.currentState.showSnackBar(SnackBar(
                    content: Text(isInside ? 'inside Area' : 'OutSide Area')));
              });
            },
            center: LatLng(35.22, -101.83),
            zoom: 5.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: url,
              additionalOptions: {
                'accessToken': accessToken,
                'id': id,
              },
            ),
            PolylineLayerOptions(
              polylines: [
                Polyline(
                  // borderStrokeWidth: 5.0,
                  // color: Colors.yellow,
                  borderColor: Colors.red,
                  strokeWidth: 5.0,
                  gradientColors: [Colors.blue],
                  // isDotted: true,
                  points: points,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

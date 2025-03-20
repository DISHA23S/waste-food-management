import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

class MapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String restaurantName;

  const MapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.restaurantName,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  double _zoom = 15.0;

  void _shareLocation() {
    final String locationUrl =
        "https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}";
    final String message =
        "Check out ${widget.restaurantName} here: $locationUrl";

    Share.share(message, subject: "${widget.restaurantName} Location");
  }

  void _zoomIn() {
    setState(() {
      _zoom += 1;
    });
  }

  void _zoomOut() {
    setState(() {
      if (_zoom > 2) {
        _zoom -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    LatLng location = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: location,
              zoom: _zoom,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: location,
                    width: 60,
                    height: 60,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoomIn",
                  onPressed: _zoomIn,
                  mini: true,
                  child: Icon(Icons.add),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoomOut",
                  onPressed: _zoomOut,
                  mini: true,
                  child: Icon(Icons.remove),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

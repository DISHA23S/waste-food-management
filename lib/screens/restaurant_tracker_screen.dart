import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_management/screens/MapScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantTracker extends StatefulWidget {
  @override
  _RestaurantTrackerState createState() => _RestaurantTrackerState();
}

class _RestaurantTrackerState extends State<RestaurantTracker> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant Tracker"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: "Search restaurants...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Firestore Data
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('waste_logs').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error loading data"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No restaurants found."));
                }

                // Extract waste entries from all documents
                List<Map<String, dynamic>> allEntries = [];

                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>? ?? {};
                  if (data.containsKey('entries')) {
                    List<dynamic> entries = data['entries'];
                    for (var entry in entries) {
                      if (entry is Map<String, dynamic>) {
                        allEntries.add(entry);
                      }
                    }
                  }
                }

                // Filter based on search query
                List<Map<String, dynamic>> filteredEntries = allEntries.where((entry) {
                  final name = (entry['restaurant'] ?? '').toLowerCase();
                  return searchQuery.isEmpty || name.contains(searchQuery);
                }).toList();

                if (filteredEntries.isEmpty) {
                  return Center(child: Text("No matching restaurants found."));
                }

                return ListView.builder(
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    final data = filteredEntries[index];

                    return ListTile(
                      title: Text(data['restaurant'] ?? "Unknown"),
                      subtitle: Text("Waste: ${data['waste_type']} | ${data['quantity']}"),
                      trailing: Icon(Icons.location_on, color: Colors.red),
                      onTap: () {
                        fetchCoordinatesAndNavigate(
                          data['location'] ?? "",
                          data['restaurant'] ?? "Unknown Restaurant",
                          context,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Fetches coordinates using OpenStreetMap API and navigates to the map screen.
  void fetchCoordinatesAndNavigate(String? location, String restaurantName, BuildContext context) async {
    if (location == null || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location is missing for $restaurantName")),
      );
      return;
    }

    try {
      print("Fetching location for: $location");

      // Use OpenStreetMap (Nominatim API)
      String url = "https://nominatim.openstreetmap.org/search?q=$location&format=json";
      Uri uri = Uri.parse(url);
      var response = await http.get(uri);
      var data = jsonDecode(response.body);

      if (data.isNotEmpty) {
        double lat = double.parse(data[0]['lat']);
        double lng = double.parse(data[0]['lon']);

        print("Coordinates found: Lat $lat, Lng $lng");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(
              latitude: lat,
              longitude: lng,
              restaurantName: restaurantName,
            ),
          ),
        );
      } else {
        print("Error: No coordinates found for $location");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not find location: $location")),
        );
      }
    } catch (e) {
      print("Error fetching location: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching location: ${e.toString()}")),
      );
    }
  }
}

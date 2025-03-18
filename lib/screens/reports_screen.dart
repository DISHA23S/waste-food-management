import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Waste Reports")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('waste_logs').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          if (reports.isEmpty) {
            return Center(child: Text("No waste reports available."));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final data = reports[index].data() as Map<String, dynamic>;
              final date = data['date'] ?? 'Unknown Date';
              final entries = data['entries'] as List<dynamic>? ?? [];

              final cookedFoodWaste = entries.where((entry) => entry['category'] == "Cooked Food Waste").toList();
              final rawFoodWaste = entries.where((entry) => entry['category'] == "Raw Food Waste").toList();

              return Card(
                margin: EdgeInsets.all(10),
                child: ExpansionTile(
                  title: Text("Waste Report - $date"),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Cooked Food Waste:", style: TextStyle(fontWeight: FontWeight.bold)),
                          ...cookedFoodWaste.map((item) => Text("${item['waste_type']} - ${item['quantity']}")),
                          SizedBox(height: 10),
                          Text("Raw Food Waste:", style: TextStyle(fontWeight: FontWeight.bold)),
                          ...rawFoodWaste.map((item) => Text("${item['waste_type']} - ${item['quantity']}")),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

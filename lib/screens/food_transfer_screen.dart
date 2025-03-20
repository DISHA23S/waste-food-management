import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransferScreen extends StatefulWidget {
  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  String filterStatus = "All"; // Default filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Food Transfer Records")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Filter by Status",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              value: filterStatus,
              items: ["All", "Pending", "Transferred"].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  filterStatus = value!;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchCombinedData(),
              builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final combinedData = snapshot.data!.where((data) {
                  if (filterStatus == "All") return true;
                  return data['status'] == filterStatus;
                }).toList();

                if (combinedData.isEmpty) {
                  return const Center(child: Text("No records found"));
                }

                return ListView.builder(
                  itemCount: combinedData.length,
                  itemBuilder: (context, index) {
                    final data = combinedData[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 4,
                      child: ListTile(
                        leading: const Icon(Icons.local_shipping, color: Colors.blue),
                        title: Text("Restaurant: ${data['restaurant'] ?? 'Unknown'}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Location: ${data['location'] ?? 'Unknown'}"),
                            Text("Waste Type: ${data['waste_type'] ?? 'Unknown'}"),
                            Text("Quantity: ${data['quantity'] ?? 0} kg"),
                          ],
                        ),
                        trailing: Column(
                          children: [
                            Text(
                              data['status'] ?? "Unknown",
                              style: TextStyle(
                                color: _getStatusColor(data['status']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              child: const Text("View Details"),
                              onPressed: () => _showDetailsDialog(data),
                            ),
                          ],
                        ),
                      ),
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

  Future<List<Map<String, dynamic>>> fetchCombinedData() async {
    final foodTransfers = await FirebaseFirestore.instance.collection('food_transfers').get();
    final wasteLogs = await FirebaseFirestore.instance.collection('waste_logs').get();

    List<Map<String, dynamic>> transfersData = foodTransfers.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();

    // waste_logs.entries[0] pattern
    List<Map<String, dynamic>> wasteData = [];
    for (var doc in wasteLogs.docs) {
      var entries = doc.data()['entries'];
      if (entries != null && entries is List) {
        for (var entry in entries) {
          wasteData.add(entry as Map<String, dynamic>);
        }
      }
    }

    return [...transfersData, ...wasteData];
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Transferred":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showDetailsDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Transfer Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.entries.map((e) {
            return Text("${e.key}: ${e.value}");
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
        ],
      ),
    );
  }
}

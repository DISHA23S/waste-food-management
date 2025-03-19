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
      appBar: AppBar(title: const Text("Food Transfer Tracking")),
      body: Column(
        children: [
          // 🔽 Dropdown for filtering transfers
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Filter by Status",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              value: filterStatus,
              items: ["All", "Pending", "In Transit", "Completed"].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  filterStatus = value!;
                });
              },
            ),
          ),
          // 🔽 List of transfers from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('transfers').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter data based on selected status
                final transfers = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (filterStatus == "All") return true;
                  return data['status'] == filterStatus;
                }).toList();

                if (transfers.isEmpty) {
                  return const Center(child: Text("No transfers found"));
                }

                return ListView.builder(
                  itemCount: transfers.length,
                  itemBuilder: (context, index) {
                    final data = transfers[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text("Restaurant: ${data['restaurant'] ?? 'Unknown'}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Donation Center: ${data['donation_center'] ?? 'Unknown'}"),
                            Text("Quantity: ${data['quantity'] ?? 0} kg"),
                          ],
                        ),
                        trailing: Text(
                          data['status'] ?? "Unknown",
                          style: TextStyle(
                            color: _getStatusColor(data['status']),
                            fontWeight: FontWeight.bold,
                          ),
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

  /// 🔵 Function to return color based on status
  Color _getStatusColor(String? status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "In Transit":
        return Colors.blue;
      case "Completed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

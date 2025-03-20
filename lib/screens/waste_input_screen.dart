import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WasteInputScreen extends StatefulWidget {
  @override
  _WasteInputScreenState createState() => _WasteInputScreenState();
}

class _WasteInputScreenState extends State<WasteInputScreen> {
  String selectedCategory = "";
  List<Map<String, dynamic>> wasteEntries = [];
  final TextEditingController restaurantNameController = TextEditingController();
  final TextEditingController wasteTypeController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  DateTime? selectedDate;
  int? editingIndex;

  final Color cookedFoodColor = Colors.blue.shade600;
  final Color rawFoodColor = Colors.orange.shade600;
  final Color backgroundColor = Colors.grey.shade200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Waste Management"),
        actions: [
          IconButton(
            icon: Icon(Icons.local_shipping),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WasteDashboardScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: selectedCategory.isEmpty ? _buildCategorySelection() : _buildWasteInputForm(),
      ),
    );
  }

  // Category selection
  Widget _buildCategorySelection() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCategoryBox("Cooked Food Waste", cookedFoodColor),
              SizedBox(width: 20),
              _buildCategoryBox("Raw Food Waste", rawFoodColor),
            ],
          ),
          SizedBox(height: 20),
          _buildWasteList(),
          ElevatedButton(
            onPressed: _submitToFirestore,
            child: Text("Submit All"),
          ),
        ],
      ),
    );
  }

  // Category Box UI
  Widget _buildCategoryBox(String title, Color borderColor) {
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = title),
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: borderColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Waste Input Form
  Widget _buildWasteInputForm() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$selectedCategory Entry", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          TextField(controller: restaurantNameController, decoration: InputDecoration(labelText: "Restaurant Name")),
          SizedBox(height: 10),
          TextField(controller: wasteTypeController, decoration: InputDecoration(labelText: "Waste Type")),
          SizedBox(height: 10),
          TextField(controller: quantityController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Quantity")),
          SizedBox(height: 10),
          TextField(controller: locationController, decoration: InputDecoration(labelText: "Location")),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(selectedDate == null ? "Select Date" : "Date: ${selectedDate!.toLocal()}".split(' ')[0]),
              ),
              IconButton(icon: Icon(Icons.calendar_today), onPressed: _pickDate),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: _saveWasteEntry, child: Text(editingIndex == null ? "Add Entry" : "Update Entry")),
          SizedBox(height: 20),
          TextButton(onPressed: () => setState(() => selectedCategory = ""), child: Text("Go Back")),
        ],
      ),
    );
  }

  // Waste List on Main Page
  Widget _buildWasteList() {
    return Column(
      children: wasteEntries.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> waste = entry.value;

        return Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            title: Text("${waste['restaurant']} - ${waste['waste_type']} - ${waste['quantity']}"),
            subtitle: Text("Date: ${waste['date']}\nLocation: ${waste['location']}\nStatus: ${waste['status']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      restaurantNameController.text = waste['restaurant'];
                      wasteTypeController.text = waste['waste_type'];
                      quantityController.text = waste['quantity'];
                      locationController.text = waste['location'];
                      selectedDate = DateTime.parse(waste['date']);
                      editingIndex = index;
                      selectedCategory = waste['category'];
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => wasteEntries.removeAt(index)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() => selectedDate = pickedDate);
    }
  }

  void _saveWasteEntry() {
    if (restaurantNameController.text.isNotEmpty &&
        wasteTypeController.text.isNotEmpty &&
        quantityController.text.isNotEmpty &&
        selectedDate != null &&
        locationController.text.isNotEmpty) {
      final entry = {
        "restaurant": restaurantNameController.text,
        "category": selectedCategory,
        "waste_type": wasteTypeController.text,
        "quantity": quantityController.text,
        "location": locationController.text,
        "date": selectedDate!.toLocal().toString().split(' ')[0],
        "status": "Pending",
      };

      setState(() {
        if (editingIndex != null) {
          wasteEntries[editingIndex!] = entry;
          editingIndex = null;
        } else {
          wasteEntries.add(entry);
        }

        restaurantNameController.clear();
        wasteTypeController.clear();
        quantityController.clear();
        locationController.clear();
        selectedDate = null;
      });
    }
  }

  void _submitToFirestore() {
    if (wasteEntries.isEmpty) return;

    FirebaseFirestore.instance.collection('waste_logs').add({
      "entries": wasteEntries,
      "timestamp": FieldValue.serverTimestamp(),
    }).then((_) {
      setState(() => wasteEntries.clear());
    });
  }
}

// Dashboard screen that opens via truck icon
class WasteDashboardScreen extends StatelessWidget {
  const WasteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pending Transfers")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('waste_logs').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final wasteLogs = snapshot.data!.docs;

          return ListView(
            children: wasteLogs.expand((doc) {
              final docId = doc.id;
              final entries = doc['entries'] as List<dynamic>;

              return entries
                  .asMap()
                  .entries
                  .where((e) => e.value['status'] == "Pending")
                  .map((e) => ListTile(
                        title: Text("${e.value['restaurant']} - ${e.value['waste_type']}"),
                        subtitle: Text("Qty: ${e.value['quantity']} | Date: ${e.value['date']}"),
                        trailing: ElevatedButton(
                          child: Text("Transfer"),
                          onPressed: () => _markAsTransferred(docId, e.key, e.value),
                        ),
                      ))
                  .toList();
            }).toList(),
          );
        },
      ),
    );
  }

  void _markAsTransferred(String docId, int index, Map<String, dynamic> item) async {
    final docRef = FirebaseFirestore.instance.collection('waste_logs').doc(docId);

    final snapshot = await docRef.get();
    if (snapshot.exists) {
      List<dynamic> updatedEntries = List.from(snapshot['entries']);
      updatedEntries[index]['status'] = "Transferred";
      await docRef.update({'entries': updatedEntries});
    }
  }
}

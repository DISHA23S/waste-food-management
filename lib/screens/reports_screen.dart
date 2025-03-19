import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Waste Reports"),
        actions: [
          // 🔽 Download Whole Report Button at the Top Right
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              final reports = await FirebaseFirestore.instance
                  .collection('waste_logs')
                  .orderBy('timestamp', descending: true)
                  .get();
              generateAndPrintPDF(reports.docs, isIndividual: false);
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('waste_logs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
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

              // Extract Date from Timestamp
              final Timestamp? timestamp = data['timestamp'];
              final String date = timestamp != null
                  ? DateFormat('yyyy-MM-dd').format(timestamp.toDate())
                  : 'Unknown Date';

              // ✅ Fetch Restaurant Name from the first waste entry instead of directly from `data`
              final List<dynamic> entries = (data['entries'] as List<dynamic>?) ?? [];
              final String restaurantName = entries.isNotEmpty
                  ? (entries[0]['restaurant'] ?? "Unknown Restaurant")
                  : "Unknown Restaurant";

              final cookedFoodWaste = entries
                  .where((entry) => entry['category'] == "Cooked Food Waste")
                  .toList();
              final rawFoodWaste = entries
                  .where((entry) => entry['category'] == "Raw Food Waste")
                  .toList();

              return Card(
                margin: EdgeInsets.all(10),
                child: ExpansionTile(
                  title: Text("Waste Report - $date"),
                  subtitle: Text("Restaurant: $restaurantName"),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Cooked Food Waste:", style: TextStyle(fontWeight: FontWeight.bold)),
                          ...cookedFoodWaste.map((item) => Text(
                                "${item['waste_type'] ?? 'Unknown'} - ${item['quantity'] ?? 'N/A'}",
                              )),
                          SizedBox(height: 10),
                          Text("Raw Food Waste:", style: TextStyle(fontWeight: FontWeight.bold)),
                          ...rawFoodWaste.map((item) => Text(
                                "${item['waste_type'] ?? 'Unknown'} - ${item['quantity'] ?? 'N/A'}",
                              )),
                          SizedBox(height: 10),
                          // ✅ Individual Report Download Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(Icons.download, color: Colors.blue),
                              onPressed: () {
                                generateAndPrintPDF([reports[index]], isIndividual: true);
                              },
                            ),
                          ),
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

  /// 📝 **Generate PDF Report**
  Future<void> generateAndPrintPDF(List<QueryDocumentSnapshot> reports, {required bool isIndividual}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                isIndividual ? "Individual Waste Report" : "Full Waste Report",
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              ...reports.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final Timestamp? timestamp = data['timestamp'];
                final String date = timestamp != null
                    ? DateFormat('yyyy-MM-dd').format(timestamp.toDate())
                    : 'Unknown Date';

                // ✅ Fetch Restaurant Name from the first waste entry for PDF
                final List<dynamic> entries = (data['entries'] as List<dynamic>?) ?? [];
                final String restaurantName = entries.isNotEmpty
                    ? (entries[0]['restaurant'] ?? "Unknown Restaurant")
                    : "Unknown Restaurant";

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Waste Report - $date", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Restaurant: $restaurantName", style: pw.TextStyle(fontSize: 14)),
                    pw.SizedBox(height: 5),
                    ...entries.map((entry) {
                      return pw.Text(
                        "${entry['waste_type'] ?? 'Unknown'} - ${entry['quantity'] ?? 'N/A'} (${entry['category'] ?? 'Uncategorized'})",
                      );
                    }).toList(),
                    pw.SizedBox(height: 15),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}

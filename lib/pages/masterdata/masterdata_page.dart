import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MasterDataPage extends StatefulWidget {
  @override
  _MasterDataPageState createState() => _MasterDataPageState();
}

class _MasterDataPageState extends State<MasterDataPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Fungsi pilih & upload CSV ke Firestore
  Future<void> _uploadCSV(String collectionName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) return;

    File file = File(result.files.single.path!);
    final raw = await file.readAsString();

    List<List<dynamic>> csvTable =
        const CsvToListConverter(fieldDelimiter: ";", eol: "\n").convert(raw);

    setState(() => _isUploading = true);

    try {
      List<dynamic> header = csvTable.first;

      for (int i = 1; i < csvTable.length; i++) {
        Map<String, dynamic> rowData = {};
        for (int j = 0; j < header.length; j++) {
          rowData[header[j].toString().toLowerCase()] =
              j < csvTable[i].length ? csvTable[i][j].toString() : "";
        }
        await FirebaseFirestore.instance.collection(collectionName).add(rowData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload ke $collectionName selesai ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload: $e")),
      );
    }

    setState(() => _isUploading = false);
  }

  /// Widget tampilkan data ICD
  Widget _buildDataList(String collectionName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return Center(child: Text("Belum ada data di $collectionName"));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["name"] ?? "Tanpa Nama",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    _buildDetail("Kode", data["code"]),
                    _buildDetail("Klasifikasi", data["classification"]),
                    _buildDetail("Kategori", data["category"]),
                    _buildDetail("Penularan", data["penularan"]),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Helper detail text
  Widget _buildDetail(String label, dynamic value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: "$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value?.toString() ?? "-"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Master Data"),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "icd9") _uploadCSV("icd9_data");
              if (value == "icd10") _uploadCSV("icd10_data");
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: "icd9", child: Text("Upload ICD-9")),
              PopupMenuItem(value: "icd10", child: Text("Upload ICD-10")),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "ICD-9"),
            Tab(text: "ICD-10"),
          ],
        ),
      ),
      body: _isUploading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDataList("icd9_data"),
                _buildDataList("icd10_data"),
              ],
            ),
    );
  }
}

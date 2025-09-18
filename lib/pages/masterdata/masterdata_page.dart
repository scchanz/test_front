import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:test_front/pages/masterdata/service/masterdata_service.dart';

class MasterDataPage extends StatelessWidget {
  const MasterDataPage({super.key});

  Future<void> _importCSV(BuildContext context, String collection) async {
    try {
      // Pilih file CSV
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final csvString = await file.readAsString();

        // Convert CSV → List<List<dynamic>>
        List<List<dynamic>> csvRows = const CsvToListConverter()
            .convert(csvString);

        if (csvRows.isEmpty) {
          throw Exception("File CSV kosong");
        }

        // PENTING: Skip baris pertama (header) dan kolom pertama (nomor urut)
        // Ambil header dari baris pertama tapi skip kolom pertama (index 0)
        final rawHeaders = csvRows[0];
        final headers = rawHeaders.length > 1 
            ? rawHeaders.sublist(1).map((e) => e.toString().trim()).toList()
            : [];

        print("Raw headers: $rawHeaders");
        print("Headers detected (skip first column): $headers");
        print("Total headers: ${headers.length}");
        print("Total rows (including header): ${csvRows.length}");

        // Data rows dimulai dari index 1 (skip header)
        final dataRows = csvRows.sublist(1);
        print("Data rows to process: ${dataRows.length}");

        if (dataRows.isEmpty) {
          throw Exception("Tidak ada data untuk diimpor (hanya header)");
        }

        if (headers.isEmpty) {
          throw Exception("Tidak ada kolom data untuk diimpor (hanya nomor urut)");
        }

        final service = MasterDataService();
        List<Map<String, dynamic>> dataList = [];
        int errorCount = 0;

        // Proses setiap baris data (bukan header)
        for (int i = 0; i < dataRows.length; i++) {
          try {
            final rawRow = dataRows[i];
            // Skip kolom pertama (nomor urut) dari setiap row
            final row = rawRow.length > 1 ? rawRow.sublist(1) : [];
            
            print("Processing row ${i + 1}:");
            print("  Raw row: $rawRow");
            print("  Data row (skip first): $row");

            if (row.isEmpty) {
              print("Skipping row ${i + 1}: No data columns");
              continue;
            }

            // Buat map data dengan semua kolom yang tersedia (tanpa kolom nomor urut)
            Map<String, dynamic> dataMap = {};
            
            // Isi data sesuai dengan jumlah kolom yang ada (skip kolom pertama)
            for (int j = 0; j < headers.length; j++) {
              String headerKey = 'column_${j + 1}'; // column_1, column_2, dst
              String headerName = headers[j];
              String cellValue = j < row.length ? row[j].toString().trim() : '';
              
              dataMap[headerKey] = cellValue;
              dataMap['${headerKey}_name'] = headerName; // Simpan nama header juga
            }

            // Skip baris jika semua kolom data kosong
            bool hasData = dataMap.values.any((value) => 
                value is String && value.isNotEmpty && !value.contains('_name'));
            
            if (!hasData) {
              print("Skipping empty data row ${i + 1}");
              continue;
            }

            // Tambah metadata
            dataMap['csvRowNumber'] = i + 1; // Nomor baris di CSV (tanpa header)
            dataMap['originalRowNumber'] = i + 2; // Nomor baris asli di file (termasuk header)
            dataMap['totalColumnsInRow'] = row.length; // Jumlah kolom data (tanpa nomor urut)
            dataMap['totalDataColumns'] = headers.length; // Total kolom header
            
            // Untuk backward compatibility dengan kode lama
            if (dataMap['column_1'] != null && dataMap['column_1'].toString().isNotEmpty) {
              dataMap['code'] = dataMap['column_1'];
              dataMap['csvId'] = dataMap['column_1'];
            }
            if (dataMap['column_2'] != null && dataMap['column_2'].toString().isNotEmpty) {
              dataMap['description'] = dataMap['column_2'];
            }

            dataList.add(dataMap);
          } catch (e) {
            errorCount++;
            print("Error processing row ${i + 1}: $e");
          }
        }

        if (dataList.isEmpty) {
          throw Exception("Tidak ada data valid untuk diimpor");
        }

        // Batch import ke Firestore
        await service.batchImportCSVData(collection, dataList, headers.cast<String>());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ Import CSV berhasil!\n"
              "📊 Data Headers: ${headers.length} kolom (skip kolom nomor)\n"
              "✔️ Berhasil: ${dataList.length} baris\n"
              "❌ Error: $errorCount baris\n"
              "📝 Total baris CSV: ${csvRows.length} (skip header)\n"
              "🗂️ Kolom yang diimpor: ${headers.join(', ')}",
            ),
            duration: const Duration(seconds: 6),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Master Data ICD"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "ICD9"),
              Tab(text: "ICD10"),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "import_icd9") {
                  _importCSV(context, "icd9");
                } else if (value == "import_icd10") {
                  _importCSV(context, "icd10");
                } else if (value == "show_format") {
                  _showCSVFormatDialog(context);
                } else if (value == "clear_icd9") {
                  _showClearConfirmation(context, "icd9");
                } else if (value == "clear_icd10") {
                  _showClearConfirmation(context, "icd10");
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "import_icd9",
                  child: Row(
                    children: [
                      Icon(Icons.upload_file, size: 16),
                      SizedBox(width: 8),
                      Text("Import CSV ICD9"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: "import_icd10",
                  child: Row(
                    children: [
                      Icon(Icons.upload_file, size: 16),
                      SizedBox(width: 8),
                      Text("Import CSV ICD10"),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: "show_format",
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, size: 16),
                      SizedBox(width: 8),
                      Text("Format CSV"),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: "clear_icd9",
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Clear ICD9", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: "clear_icd10",
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Clear ICD10", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            ICDList(collection: "icd9"),
            ICDList(collection: "icd10"),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, String collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus Semua Data ${collection.toUpperCase()}"),
        content: const Text(
          "Apakah Anda yakin ingin menghapus SEMUA data? "
          "Tindakan ini tidak dapat dibatalkan!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final service = MasterDataService();
                await service.clearCollection(collection);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("✅ Semua data ${collection.toUpperCase()} telah dihapus"),
                    backgroundColor: Colors.orange,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("❌ Error: $e"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Hapus Semua", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCSVFormatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Format CSV"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "📋 Panduan Format CSV:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                "✅ Yang BENAR:",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const Text("• Baris pertama adalah HEADER (akan di-skip)"),
              const Text("• Kolom pertama adalah NOMOR URUT (akan di-skip)"),
              const Text("• Sistem hanya membaca DATA MURNI (tanpa nomor & header)"),
              const Text("• Kolom kosong akan disimpan sebagai string kosong"),
              const SizedBox(height: 12),
              const Text(
                "❌ Yang akan DIABAIKAN:",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const Text("• Baris pertama (header) - tidak masuk ke database"),
              const Text("• Kolom pertama (nomor urut) - tidak masuk ke database"),
              const Text("• Baris yang semua kolomnya kosong"),
              const SizedBox(height: 16),
              const Text(
                "📝 Contoh CSV yang benar:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                
                child: const Text(
                  "No,Kode,Nama Penyakit,Kategori,Status,Keterangan\n"
                  "1,A01.0,Demam Tifoid,Infeksi,Aktif,Umum\n"
                  "2,A01.1,Paratifoid A,Infeksi,Review,Jarang\n"
                  "3,B02.0,Herpes Zoster,Virus,Aktif,Kritis\n"
                  "4,C78.1,Metastase Paru,Tumor,Aktif,Serius",
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "🔍 Hasil setelah import:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text("• Header yang tersimpan: Kode, Nama Penyakit, Kategori, Status, Keterangan"),
              const Text("• Data: 4 baris akan tersimpan (nomor urut diabaikan)"),
              const Text("• Kolom 'No' tidak akan tersimpan"),
              const Text("• Header row tidak akan tersimpan sebagai data"),
              const Text("• Struktur: column_1=Kode, column_2=Nama Penyakit, dst"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Mengerti"),
          ),
        ],
      ),
    );
  }
}

class ICDList extends StatelessWidget {
  final String collection;
  const ICDList({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .orderBy("uniqueId")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.table_chart, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("Belum ada data", style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text(
                  "Import file CSV untuk memulai",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final headers = data['headers'] as List<dynamic>? ?? [];
            final uniqueId = data['uniqueId'] ?? 0;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    uniqueId.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(
                  data['column_2'] ?? data['description'] ?? 'No description',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ID: $uniqueId | Kode: ${data['column_1'] ?? data['code'] ?? 'N/A'}"),
                    if (headers.isNotEmpty)
                      Text(
                        "Data Kolom: ${headers.length} | Baris CSV: ${data['csvRowNumber'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Unique ID: $uniqueId",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    if (data['csvRowNumber'] != null)
                                      Text("Baris Data: ${data['csvRowNumber']} (skip header)"),
                                    if (data['totalDataColumns'] != null)
                                      Text("Kolom Data: ${data['totalDataColumns']} (skip nomor urut)"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Dynamic columns
                        ...List.generate(headers.length, (i) {
                          final columnKey = 'column_${i + 1}';
                          final columnValue = data[columnKey]?.toString() ?? '';
                          final headerName = headers[i].toString();
                          
                          if (columnValue.isEmpty) return const SizedBox.shrink();
                          
                          return _buildDataRow(
                            "Kolom ${i + 1}",
                            columnValue,
                            headerName,
                            _getColorForIndex(i),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }

  Widget _buildDataRow(String label, String value, String headerName, Color color) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label.split(' ')[1], // Ambil angka dari "Kolom X"
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headerName,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
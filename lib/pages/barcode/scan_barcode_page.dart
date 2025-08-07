import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode RM'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!isScanning) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() {
                    isScanning = false;
                  });
                  _searchRekamMedis(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          _buildScannerOverlay(),
          if (!isScanning)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isScanning = true;
          });
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Stack(
      children: [
        // Dark overlay
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  height: 200,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Scan area border
        Center(
          child: Container(
            height: 200,
            width: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner indicators
                _buildCornerIndicator(Alignment.topLeft),
                _buildCornerIndicator(Alignment.topRight),
                _buildCornerIndicator(Alignment.bottomLeft),
                _buildCornerIndicator(Alignment.bottomRight),
              ],
            ),
          ),
        ),
        // Instructions
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: const Text(
              'Arahkan kamera ke barcode nomor RM untuk memindai',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCornerIndicator(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                ? const BorderSide(color: Colors.red, width: 3)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                ? const BorderSide(color: Colors.red, width: 3)
                : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                ? const BorderSide(color: Colors.red, width: 3)
                : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                ? const BorderSide(color: Colors.red, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Future<void> _searchRekamMedis(String noRm) async {
    try {
      // Search for rekam medis with matching no_rm
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rekam_medis')
          .where('no_rm', isEqualTo: noRm)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final DocumentSnapshot document = querySnapshot.docs.first;
        _showRekamMedisResult(document);
      } else {
        _showNotFoundDialog(noRm);
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan saat mencari data: $e');
    }
  }

  void _showRekamMedisResult(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Data Rekam Medis Ditemukan'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDataRow('Nama Pasien', data['nama_pasien']),
                _buildDataRow('No. RM', data['no_rm']),
                _buildDataRow('Tanggal', data['tanggal']),
                const Divider(),
                _buildDataRow('Subjective', data['subjective']),
                _buildDataRow('Objective', data['objective']),
                _buildDataRow('Assessment', data['assessment']),
                _buildDataRow('Plan', data['plan']),
                _buildDataRow('Instruction', data['instruction']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isScanning = true;
                });
              },
              child: const Text('Scan Lagi'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                // Navigate to detail page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => _buildDetailPage(document),
                  ),
                );
              },
              child: const Text('Lihat Detail'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPage(DocumentSnapshot document) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail dari Scan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildDetailContent(document),
      ),
    );
  }

  Widget _buildDetailContent(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Pasien',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem('Nama Pasien', data['nama_pasien']),
                  _buildDetailItem('No. RM', data['no_rm']),
                  _buildDetailItem('Tanggal', data['tanggal']),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data SOAPI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem('Subjective (S)', data['subjective']),
                  _buildDetailItem('Objective (O)', data['objective']),
                  _buildDetailItem('Assessment (A)', data['assessment']),
                  _buildDetailItem('Plan (P)', data['plan']),
                  _buildDetailItem('Instruction (I)', data['instruction']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value?.toString() ?? '-',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotFoundDialog(String noRm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Data Tidak Ditemukan'),
          content: Text('Rekam medis dengan nomor RM "$noRm" tidak ditemukan dalam database.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isScanning = true;
                });
              },
              child: const Text('Scan Lagi'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isScanning = true;
                });
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_front/pages/barcode/widgets/rekam_medis_service.dart';
import 'package:test_front/pages/barcode/widgets/result_dialog.dart';
import 'package:test_front/pages/barcode/widgets/scanner_overlay.dart';
import 'package:test_front/pages/rekammedis/detail_rm.dart';


class ScanBarcodePage extends StatefulWidget {
  const ScanBarcodePage({super.key});

  @override
  State<ScanBarcodePage> createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;
  final RekamMedisService _rekamMedisService = RekamMedisService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Camera Scanner
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // Scanner Overlay
          ScannerOverlay(),
          
          // Loading Indicator
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
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Scan Barcode RM'),
      backgroundColor: const Color(0xFF2563EB),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.flash_on),
          onPressed: () => cameraController.toggleTorch(),
          tooltip: 'Toggle Flash',
        ),
        IconButton(
          icon: const Icon(Icons.flip_camera_ios),
          onPressed: () => cameraController.switchCamera(),
          tooltip: 'Switch Camera',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          isScanning = true;
        });
      },
      backgroundColor: const Color(0xFF2563EB),
      child: const Icon(Icons.refresh, color: Colors.white),
    );
  }

  void _onDetect(BarcodeCapture capture) {
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
  }

  Future<void> _searchRekamMedis(String noRm) async {
    try {
      final DocumentSnapshot? document = await _rekamMedisService.searchByNoRm(noRm);
      
      if (document != null) {
        _showResultDialog(document);
      } else {
        _showNotFoundDialog(noRm);
      }
    } catch (e) {
      _showErrorDialog('Terjadi kesalahan saat mencari data: $e');
    }
  }

  void _showResultDialog(DocumentSnapshot document) {
    ResultDialog.showFound(
      context: context,
      document: document,
      onScanAgain: () {
        setState(() {
          isScanning = true;
        });
      },
      onViewDetail: () {
        Navigator.of(context).pop(); // Close scanner
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailRekamMedisPage(document: document),
          ),
        );
      },
    );
  }

  void _showNotFoundDialog(String noRm) {
    ResultDialog.showNotFound(
      context: context,
      noRm: noRm,
      onScanAgain: () {
        setState(() {
          isScanning = true;
        });
      },
      onClose: () {
        Navigator.of(context).pop();
      },
    );
  }

  void _showErrorDialog(String message) {
    ResultDialog.showError(
      context: context,
      message: message,
      onRetry: () {
        setState(() {
          isScanning = true;
        });
      },
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
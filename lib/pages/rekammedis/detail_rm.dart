import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_widget/barcode_widget.dart';

class DetailRekamMedisPage extends StatelessWidget {
  final DocumentSnapshot document;

  const DetailRekamMedisPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final data = document.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Rekam Medis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailItem('Nama Pasien', data['nama_pasien']),
            _buildDetailItem('Nomor RM', data['no_rm']),
            
            // Barcode Section
            const SizedBox(height: 16),
            _buildBarcodeSection(data['no_rm']),
            
            const Divider(height: 32),

            _buildDetailItem('Subjective (S)', data['subjective']),
            _buildDetailItem('Objective (O)', data['objective']),
            _buildDetailItem('Assessment (A)', data['assessment']),
            _buildDetailItem('Plan (P)', data['plan']),
            _buildDetailItem('Instruction (I)', data['instruction']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: RichText(
        text: TextSpan(
          text: '$label:\n',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: value ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeSection(String? noRm) {
    if (noRm == null || noRm.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Barcode Nomor RM',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: noRm,
              width: 250,
              height: 80,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No. RM: $noRm',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

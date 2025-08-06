import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_widget/barcode_widget.dart';

class DetailRekamMedisPage extends StatelessWidget {
  final DocumentSnapshot document;

  const DetailRekamMedisPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final data = Map<String, dynamic>.from(document.data() as Map);

    // Ambil SOAP dari field "soap" atau langsung dari root
    final soap = Map<String, dynamic>.from(data['soap'] ?? {});
    final subjective = soap['subjective'] ?? data['subjective'];
    final objective = soap['objective'] ?? data['objective'];
    final assessment = soap['assessment'] ?? data['assessment'];
    final plan = soap['plan'] ?? data['plan'];
    final instruction = soap['instruction'] ?? data['instruction'];

    // Ambil tambahan
    final tambahan = Map<String, dynamic>.from(data['tambahan'] ?? {});

    // Ambil daftar obat
    final obatList = List<Map<String, dynamic>>.from(data['obat_list'] ?? []);

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
            const SizedBox(height: 16),
            _buildBarcodeSection(data['no_rm']),
            const Divider(height: 32),

            // SOAPI
            _buildDetailItem('Subjective (S)', subjective),
            _buildDetailItem('Objective (O)', objective),
            _buildDetailItem('Assessment (A)', assessment),
            _buildDetailItem('Plan (P)', plan),
            _buildDetailItem('Instruction (I)', instruction),

            const Divider(height: 32),

            // Tambahan
            if (tambahan.isNotEmpty) ...[
              const Text(
                'Tambahan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...tambahan.entries.map((e) =>
                  _buildDetailItem(e.key, e.value?.toString())),
              const Divider(height: 32),
            ],

            // Daftar Obat
            if (obatList.isNotEmpty) ...[
              const Text(
                'Daftar Obat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...obatList.map((obat) {
                final nama = obat['nama'] ?? '-';
                final dosis = obat['dosis'] ?? '-';
                final jumlah = obat['jumlah']?.toString() ?? '-';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '$nama — Dosis: $dosis — Jumlah: $jumlah',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, dynamic value) {
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
              text: value?.toString() ?? '-',
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
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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

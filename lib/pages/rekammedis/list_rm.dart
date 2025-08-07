import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_front/pages/rekammedis/detail_rm.dart';

class LihatRekamMedisPage extends StatelessWidget {
  const LihatRekamMedisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Rekam Medis')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rekam_medis')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada data rekam medis'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Pasien: ${data['nama_pasien'] ?? ''}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No RM: ${data['no_rm'] ?? ''}'),
                      const SizedBox(height: 8),
                      Text('S: ${data['subjective'] ?? ''}'),
                      Text('O: ${data['objective'] ?? ''}'),
                      Text('A: ${data['assessment'] ?? ''}'),
                      Text('P: ${data['plan'] ?? ''}'),
                      Text('I: ${data['instruction'] ?? ''}'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailRekamMedisPage(document: docs[index])));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

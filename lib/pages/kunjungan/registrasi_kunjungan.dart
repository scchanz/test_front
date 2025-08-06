import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RegistrasiKunjunganPage extends StatefulWidget {
  const RegistrasiKunjunganPage({super.key});

  @override
  State<RegistrasiKunjunganPage> createState() => _RegistrasiKunjunganPageState();
}

class _RegistrasiKunjunganPageState extends State<RegistrasiKunjunganPage> {
  final TextEditingController noRmController = TextEditingController();
  bool isLoading = false;

  final CollectionReference patients =
      FirebaseFirestore.instance.collection('patients');
  final CollectionReference visits =
      FirebaseFirestore.instance.collection('visits');

  Future<void> _buatKunjungan() async {
    final noRm = noRmController.text.trim();
    if (noRm.isEmpty) {
      _tampilkanPesan("Nomor Rekam Medis tidak boleh kosong");
      return;
    }

    setState(() => isLoading = true);

    // Cek apakah pasien dengan no_rm ada di Firestore
    final result =
        await patients.where('no_rm', isEqualTo: noRm).limit(1).get();

    if (result.docs.isEmpty) {
      setState(() => isLoading = false);
      _tampilkanPesan("Pasien dengan No RM '$noRm' tidak ditemukan");
      return;
    }

    final now = DateTime.now();
    final noKunjungan = "KJ-${DateFormat('yyyyMMddHHmmss').format(now)}";

    // Simpan kunjungan baru ke koleksi visits
    await visits.add({
      'no_rm': noRm,
      'no_kunjungan': noKunjungan,
      'tanggal_kunjungan': now.toIso8601String(),
    });

    setState(() => isLoading = false);
    _tampilkanPesan("Kunjungan berhasil dibuat: $noKunjungan");

    // Bersihkan input
    noRmController.clear();
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrasi Kunjungan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: noRmController,
              decoration: const InputDecoration(
                labelText: 'Nomor Rekam Medis',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _buatKunjungan,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Buat Kunjungan"),
            ),
          ],
        ),
      ),
    );
  }
}

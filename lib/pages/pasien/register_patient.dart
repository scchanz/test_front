import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RegisterPatientPage extends StatefulWidget {
  const RegisterPatientPage({super.key});

  @override
  State<RegisterPatientPage> createState() => _RegisterPatientPageState();
}

class _RegisterPatientPageState extends State<RegisterPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthPlaceController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController mrnController = TextEditingController();

  DateTime? selectedDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    mrnController.text = generateRandomMRN(); // Set initial MRN
  }

  String generateRandomMRN() {
    final random = Random();
    final number = random.nextInt(900000) + 100000; // 6 digit
    return 'RM-$number';
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _submitPatient() async {
    if (!_formKey.currentState!.validate() || selectedDate == null) return;

    setState(() => isLoading = true);

    final patientData = {
      'medical_record_number': mrnController.text.trim(),
      'name': nameController.text.trim(),
      'birth_place': birthPlaceController.text.trim(),
      'date_of_birth': selectedDate!.toIso8601String(),
      'address': addressController.text.trim(),
      'phone': phoneController.text.trim(),
      'created_at': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('patients').add(patientData);

    setState(() => isLoading = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pasien berhasil ditambahkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi Pasien'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: mrnController,
                decoration: InputDecoration(
                  labelText: 'No Rekam Medis',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        mrnController.text = generateRandomMRN();
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'No rekam medis wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Masukkan nama' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: birthPlaceController,
                decoration: const InputDecoration(
                  labelText: 'Tempat Lahir',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Masukkan tempat lahir' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(selectedDate == null
                    ? 'Pilih Tanggal Lahir'
                    : 'Tanggal Lahir: ${DateFormat('dd MMM yyyy').format(selectedDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Masukkan alamat' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No Telepon',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Masukkan no telepon' : null,
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitPatient,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Pasien'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

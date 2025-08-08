import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_front/pages/rekammedis/menu_rm.dart';

class InputRekamMedisPage extends StatefulWidget {
  const InputRekamMedisPage({super.key});

  @override
  State<InputRekamMedisPage> createState() => _InputRekamMedisPageState();
}

class _InputRekamMedisPageState extends State<InputRekamMedisPage> {
  final _formKey = GlobalKey<FormState>();
  final noRmController = TextEditingController();
  final namaPasienController = TextEditingController();
  final subjectiveController = TextEditingController();
  final objectiveController = TextEditingController();
  final assessmentController = TextEditingController();
  final planController = TextEditingController();
  final instructionController = TextEditingController();

  // 🟢 Controller untuk obat
  List<Map<String, TextEditingController>> obatControllers = [];

  // 🟢 Controller untuk field tambahan
  Map<String, TextEditingController> tambahanControllers = {};

  bool isLoading = false;

  Future<void> _navigateToTambahMenu() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const TambahMenuPage()),
    );

    if (result != null && !tambahanControllers.containsKey(result)) {
      setState(() {
        tambahanControllers[result] = TextEditingController();
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final Map<String, dynamic> tambahanData = {
          for (var entry in tambahanControllers.entries)
            entry.key: entry.value.text
        };

        final List<Map<String, dynamic>> obatData = obatControllers.map((map) {
          return {
            'nama_obat': map['nama']!.text,
            'dosis': map['dosis']!.text,
          };
        }).toList();

        await FirebaseFirestore.instance.collection('rekam_medis').add({
          'no_rm': noRmController.text,
          'nama_pasien': namaPasienController.text,
          'subjective': subjectiveController.text,
          'objective': objectiveController.text,
          'assessment': assessmentController.text,
          'plan': planController.text,
          'instruction': instructionController.text,
          'obat': obatData,
          'tambahan': tambahanData,
          'timestamp': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rekam medis berhasil disimpan')),
        );

        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e')),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _clearForm() {
    noRmController.clear();
    namaPasienController.clear();
    subjectiveController.clear();
    objectiveController.clear();
    assessmentController.clear();
    planController.clear();
    instructionController.clear();

    for (var controller in tambahanControllers.values) {
      controller.dispose();
    }
    tambahanControllers.clear();

    for (var map in obatControllers) {
      map['nama']?.dispose();
      map['dosis']?.dispose();
    }
    obatControllers.clear();

    setState(() {});
  }

  @override
  void dispose() {
    noRmController.dispose();
    namaPasienController.dispose();
    subjectiveController.dispose();
    objectiveController.dispose();
    assessmentController.dispose();
    planController.dispose();
    instructionController.dispose();

    for (var controller in tambahanControllers.values) {
      controller.dispose();
    }
    for (var map in obatControllers) {
      map['nama']?.dispose();
      map['dosis']?.dispose();
    }

    super.dispose();
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Tidak boleh kosong' : null,
      ),
    );
  }

  Widget _buildTambahanForms() {
    return Column(
      children: tambahanControllers.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: entry.value,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: entry.key,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Tidak boleh kosong'
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  setState(() {
                    entry.value.dispose();
                    tambahanControllers.remove(entry.key);
                  });
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 🟢 Form dinamis untuk obat
  Widget _buildObatForms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Daftar Obat",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...obatControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final map = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: map['nama'],
                    decoration: const InputDecoration(
                      labelText: 'Nama Obat',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Harus diisi' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: map['dosis'],
                    decoration: const InputDecoration(
                      labelText: 'Dosis',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Harus diisi' : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      map['nama']?.dispose();
                      map['dosis']?.dispose();
                      obatControllers.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              obatControllers.add({
                'nama': TextEditingController(),
                'dosis': TextEditingController(),
              });
            });
          },
          icon: const Icon(Icons.add),
          label: const Text("Tambah Obat"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Rekam Medis")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(noRmController, 'No. Rekam Medis'),
              _buildTextField(namaPasienController, 'Nama Pasien'),
              _buildTextField(subjectiveController, 'Subjective', maxLines: 3),
              _buildTextField(objectiveController, 'Objective', maxLines: 3),
              _buildTextField(assessmentController, 'Assessment', maxLines: 3),
              _buildTextField(planController, 'Plan', maxLines: 3),
              _buildTextField(instructionController, 'Instruction', maxLines: 3),

              const SizedBox(height: 16),
              _buildObatForms(),

              const SizedBox(height: 16),
              _buildTambahanForms(),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _navigateToTambahMenu,
                child: const Text('Tambahkan Lainnya'),
              ),
              const SizedBox(height: 20),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Simpan Rekam Medis'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

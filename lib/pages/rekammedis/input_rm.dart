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
  Map<String, dynamic> tambahanControllers =
      {}; // value: TextEditingController (parent) + Map<String, TextEditingController> (children)
  Map<String, Map<String, dynamic>> tambahanMenuMeta =
      {}; // key: nama menu, value: {tipe, opsi}

  bool isLoading = false;

  Future<void> _navigateToTambahMenu() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const TambahMenuPage()),
    );

    if (result != null && !tambahanControllers.containsKey(result)) {
      // Ambil meta menu dari Firestore
      final snap = await FirebaseFirestore.instance
          .collection('menu_tambahan')
          .where('nama', isEqualTo: result)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data();
        final tipe = data['tipe'] ?? 'single';
        final opsi = (data['opsi'] ?? []) as List<dynamic>;

        setState(() {
          tambahanMenuMeta[result] = {'tipe': tipe, 'opsi': opsi};
          if (tipe == 'list') {
            tambahanControllers[result] = {
              'parent': TextEditingController(),
              'children': {
                for (var o in opsi) o.toString(): TextEditingController(),
              },
            };
          } else {
            tambahanControllers[result] = TextEditingController();
          }
        });
      }
    }
  }

  Future<void> _pickFromMenu() async {
    // Ambil semua menu dari Firestore
    final snap = await FirebaseFirestore.instance
        .collection('menu_tambahan')
        .orderBy('nama')
        .get();

    final menus = snap.docs.map((doc) {
      final data = doc.data();
      return {
        'nama': data['nama'],
        'tipe': data['tipe'],
        'opsi': data['opsi'] ?? [],
      };
    }).toList();

    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Menu Tambahan'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: menus.length,
              itemBuilder: (context, idx) {
                final menu = menus[idx];
                final nama = menu['nama'];
                final tipe = menu['tipe'];
                return ListTile(
                  title: Text(nama ?? ''),
                  subtitle: Text('Tipe: $tipe'),
                  onTap: () => Navigator.pop(context, menu),
                );
              },
            ),
          ),
        );
      },
    );

    if (selected != null && selected['nama'] != null) {
      final nama = selected['nama'];
      final tipe = selected['tipe'];
      final opsi = selected['opsi'];

      if (!tambahanControllers.containsKey(nama)) {
        setState(() {
          tambahanMenuMeta[nama] = {'tipe': tipe, 'opsi': opsi};
          if (tipe == 'list') {
            tambahanControllers[nama] = {
              'parent': TextEditingController(),
              'children': {
                for (var o in opsi) o.toString(): TextEditingController(),
              },
            };
          } else {
            tambahanControllers[nama] = TextEditingController();
          }
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final Map<String, dynamic> tambahanData = {
          for (var entry in tambahanControllers.entries)
            entry.key: tambahanMenuMeta[entry.key]?['tipe'] == 'list'
                ? {
                    'parent': entry.value['parent'].text,
                    'children': {
                      for (var child
                          in (tambahanMenuMeta[entry.key]?['opsi'] ?? []))
                        child.toString():
                            (entry.value['children']
                                    as Map<String, TextEditingController>)[child
                                    .toString()]
                                ?.text ??
                            '',
                    },
                  }
                : entry.value.text,
        };

        final List<Map<String, dynamic>> obatData = obatControllers.map((map) {
          return {'nama_obat': map['nama']!.text, 'dosis': map['dosis']!.text};
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFromMenu,
              icon: const Icon(Icons.list),
              label: const Text('Ambil dari Menu'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tambahanControllers.entries.map((entry) {
          final meta = tambahanMenuMeta[entry.key];
          final tipe = meta?['tipe'] ?? 'single';
          final opsi = meta?['opsi'] ?? [];

          if (tipe == 'list') {
            final parentController =
                entry.value['parent'] as TextEditingController;
            final childControllers =
                entry.value['children'] as Map<String, TextEditingController>;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: parentController,
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
                            parentController.dispose();
                            for (var c in childControllers.values) {
                              c.dispose();
                            }
                            tambahanControllers.remove(entry.key);
                            tambahanMenuMeta.remove(entry.key);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...opsi.map(
                    (o) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextFormField(
                        controller: childControllers[o.toString()],
                        decoration: InputDecoration(
                          labelText: o.toString(),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Tidak boleh kosong'
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
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
                        tambahanMenuMeta.remove(entry.key);
                      });
                    },
                  ),
                ],
              ),
            );
          }
        }).toList(),
      ],
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
              _buildTextField(
                instructionController,
                'Instruction',
                maxLines: 3,
              ),

              const SizedBox(height: 16),
              _buildTambahanForms(),

              const SizedBox(height: 16),
              _buildObatForms(),
              const SizedBox(height: 20),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text(
                        'Simpan Rekam Medis',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.green,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

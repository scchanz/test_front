import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TambahMenuPage extends StatefulWidget {
  final bool fromDrawer;
  const TambahMenuPage({super.key, this.fromDrawer = false});

  @override
  State<TambahMenuPage> createState() => _TambahMenuPageState();
}

class _TambahMenuPageState extends State<TambahMenuPage> {
  final TextEditingController menuNameController = TextEditingController();
  final TextEditingController optionController = TextEditingController();

  String inputType = 'single';
  List<String> options = []; // <-- Tambahan untuk menyimpan opsi

  final CollectionReference menuCollection = FirebaseFirestore.instance
      .collection('menu_tambahan');

  Future<void> _addMenu() async {
    final name = menuNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama menu tidak boleh kosong')),
      );
      return;
    }

    if (inputType == 'list' && options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan minimal 1 opsi untuk tipe list'),
        ),
      );
      return;
    }

    final existing = await menuCollection
        .where('nama', isEqualTo: name)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Menu sudah ada')));
      return;
    }

    await menuCollection.add({
      'nama': name,
      'tipe': inputType,
      if (inputType == 'list') 'opsi': List<String>.from(options),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Menu "$name" ditambahkan sebagai $inputType')),
    );

    menuNameController.clear();
    optionController.clear();
    options.clear();
    setState(() => inputType = 'single');
  }

  Future<void> _deleteMenu(String docId, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus menu "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await menuCollection.doc(docId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Menu "$nama" dihapus')));
    }
  }

  void _selectMenu(String name) {
    if (widget.fromDrawer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Untuk menggunakan menu ini, buka melalui Form Rekam Medis.',
          ),
        ),
      );
    } else {
      Navigator.pop(context, name);
    }
  }

  void _addOption() {
    final option = optionController.text.trim();
    if (option.isEmpty) return;

    setState(() {
      options.add(option);
      optionController.clear();
    });
  }

  void _removeOption(int index) {
    setState(() => options.removeAt(index));
  }

  @override
  void dispose() {
    menuNameController.dispose();
    optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFromDrawer = widget.fromDrawer;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isFromDrawer ? 'Tambah Menu Rekam Medis' : 'Pilih Menu Tambahan',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isFromDrawer) ...[
              TextField(
                controller: menuNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Menu Baru',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Form Tambahan Jika Tipe = List (pindah ke atas)
              if (inputType == 'list') ...[
                // Penjelasan bahwa opsi adalah field anak
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: const Text(
                    'Tambahkan nama field anak (sub-form) untuk menu bertipe List.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: optionController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Field Anak',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addOption,
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (options.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Field Anak (Sub-form):",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        for (int i = 0; i < options.length; i++)
                          ListTile(
                            dense: true,
                            title: Text(options[i]),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _removeOption(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
              ],

              // Dropdown Pilih Tipe Input (sekarang di bawah form opsi)
              Row(
                children: [
                  const Text("Tipe Input: "),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: inputType,
                    items: const [
                      DropdownMenuItem(value: 'single', child: Text('Single')),
                      DropdownMenuItem(value: 'list', child: Text('List')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          inputType = value;
                          options.clear();
                        });
                      }
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _addMenu,
                    child: const Text('Tambah Menu'),
                  ),
                ],
              ),

              const Divider(height: 32),
            ],

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Daftar Menu:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: menuCollection.orderBy('nama').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(child: Text('Belum ada menu.'));
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final nama = data['nama'] ?? 'Tanpa Nama';
                      final tipe = data['tipe'] ?? 'single';

                      return ListTile(
                        title: Text(nama),
                        subtitle: Text('Tipe: $tipe'),
                        trailing: isFromDrawer
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteMenu(doc.id, nama),
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: () => _selectMenu(nama),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

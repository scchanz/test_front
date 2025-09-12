import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MasterDataPage extends StatelessWidget {
  const MasterDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Master Data ICD"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "ICD9"),
              Tab(text: "ICD10"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ICDList(collection: "icd9"),
            ICDList(collection: "icd10"),
          ],
        ),
      ),
    );
  }
}

class ICDList extends StatelessWidget {
  final String collection;
  const ICDList({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(collection)
          .orderBy("code")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Belum ada data"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final code = data['code'] ?? '';
            final description = data['description'] ?? '';

            return ListTile(
              leading: CircleAvatar(child: Text(code.toString())),
              title: Text(description),
              subtitle: Text("Kode: $code"),
            );
          },
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class MasterDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Tambah ICD9
  Future<void> addICD9(String code, String description) async {
    await _db.collection('icd9').add({
      'code': code,
      'description': description,
    });
  }

  // Tambah ICD10
  Future<void> addICD10(String code, String description) async {
    await _db.collection('icd10').add({
      'code': code,
      'description': description,
    });
  }
}

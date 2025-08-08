import 'package:cloud_firestore/cloud_firestore.dart';

class RekamMedisService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'rekam_medis';

  /// Search rekam medis by nomor RM
  Future<DocumentSnapshot?> searchByNoRm(String noRm) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('no_rm', isEqualTo: noRm)
          .limit(1) // Only get the first match
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to search rekam medis: $e');
    }
  }

  /// Search rekam medis by patient name
  Future<List<DocumentSnapshot>> searchByPatientName(String patientName) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .where('nama_pasien', isGreaterThanOrEqualTo: patientName)
          .where('nama_pasien', isLessThanOrEqualTo: '$patientName\uf8ff')
          .get();

      return querySnapshot.docs;
    } catch (e) {
      throw Exception('Failed to search by patient name: $e');
    }
  }

  /// Get rekam medis by document ID
  Future<DocumentSnapshot?> getById(String documentId) async {
    try {
      final DocumentSnapshot documentSnapshot = await _firestore
          .collection(_collection)
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        return documentSnapshot;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get rekam medis by ID: $e');
    }
  }

  /// Get recent rekam medis
  Future<List<DocumentSnapshot>> getRecent({int limit = 10}) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      throw Exception('Failed to get recent rekam medis: $e');
    }
  }
}

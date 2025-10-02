import 'package:cloud_firestore/cloud_firestore.dart';

class MasterDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method untuk generate document ID otomatis
  String _generateDocId() {
    return _firestore.collection('temp').doc().id;
  }

  // Method untuk batch import CSV data tanpa ID sequence
  Future<void> batchImportCSVData(
    String collection, 
    List<Map<String, dynamic>> dataList,
    List<String> headers,
  ) async {
    WriteBatch batch = _firestore.batch();
    
    for (int i = 0; i < dataList.length; i++) {
      final data = dataList[i];
      data['headers'] = headers;
      data['totalColumns'] = headers.length;
      data['createdAt'] = FieldValue.serverTimestamp();
      data['importBatch'] = DateTime.now().millisecondsSinceEpoch;
      
      // Generate random document ID
      String docId = _generateDocId();
      DocumentReference docRef = _firestore.collection(collection).doc(docId);
      batch.set(docRef, data);
    }
    
    await batch.commit();
  }

  // Method untuk add single data tanpa ID sequence
  Future<void> addData(String collection, Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    String docId = _generateDocId();
    await _firestore.collection(collection).doc(docId).set(data);
  }

  // Method untuk get data by document ID
  Future<DocumentSnapshot?> getByDocId(String collection, String docId) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      print("Error getting document by doc ID: $e");
      return null;
    }
  }

  // Method untuk update data by document ID
  Future<void> updateByDocId(String collection, String docId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      print("Error updating document by doc ID: $e");
    }
  }

  // Method untuk delete data by document ID
  Future<void> deleteByDocId(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      print("Error deleting document by doc ID: $e");
    }
  }

  // Method untuk clear collection tanpa counter
  Future<void> clearCollection(String collection) async {
    final batch = _firestore.batch();
    final snapshots = await _firestore.collection(collection).get();
    
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  // Method untuk search berdasarkan kolom tertentu
  Future<List<QueryDocumentSnapshot>> searchByColumn(
    String collection, 
    String columnKey, 
    String searchValue,
  ) async {
    final snapshot = await _firestore
        .collection(collection)
        .where(columnKey, isEqualTo: searchValue)
        .get();
    
    return snapshot.docs;
  }

  // Method untuk search dengan like/contains
  Future<List<QueryDocumentSnapshot>> searchByText(
    String collection, 
    String columnKey, 
    String searchText,
  ) async {
    final snapshot = await _firestore
        .collection(collection)
        .where(columnKey, isGreaterThanOrEqualTo: searchText)
        .where(columnKey, isLessThan: searchText + '\uf8ff')
        .orderBy(columnKey)
        .get();
    
    return snapshot.docs;
  }

  // Method untuk get semua data dengan pagination berdasarkan timestamp
  Future<List<QueryDocumentSnapshot>> getAllDataPaginated(
    String collection, 
    {int limit = 50, DocumentSnapshot? startAfter}
  ) async {
    Query query = _firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final snapshot = await query.get();
    return snapshot.docs;
  }

  // Method untuk get total count collection
  Future<int> getTotalCount(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print("Error getting total count: $e");
      return 0;
    }
  }

  // Method untuk export data ke format yang bisa diolah
  Future<List<Map<String, dynamic>>> exportCollectionData(String collection) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .orderBy('uniqueId')
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error exporting collection data: $e");
      return [];
    }
  }
}
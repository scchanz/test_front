import 'package:cloud_firestore/cloud_firestore.dart';

class MasterDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method untuk mendapatkan ID berikutnya
  Future<int> getNextId(String collection) async {
    try {
      // Cek counter document untuk collection ini
      DocumentSnapshot counterDoc = await _firestore
          .collection('counters')
          .doc(collection)
          .get();

      if (counterDoc.exists) {
        final data = counterDoc.data() as Map<String, dynamic>;
        return (data['lastId'] ?? 0) + 1;
      } else {
        // Jika belum ada counter, mulai dari 1
        await _firestore.collection('counters').doc(collection).set({
          'lastId': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return 1;
      }
    } catch (e) {
      print("Error getting next ID: $e");
      return 1;
    }
  }

  // Method untuk update counter ID terakhir
  Future<void> updateLastId(String collection, int lastId) async {
    try {
      await _firestore.collection('counters').doc(collection).set({
        'lastId': lastId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating last ID: $e");
    }
  }

  // Method untuk batch import CSV data dengan semua kolom
  Future<void> batchImportCSVData(
    String collection, 
    List<Map<String, dynamic>> dataList,
    List<String> headers,
  ) async {
    WriteBatch batch = _firestore.batch();
    int nextId = await getNextId(collection);
    
    for (int i = 0; i < dataList.length; i++) {
      final data = dataList[i];
      data['uniqueId'] = nextId + i;
      data['headers'] = headers;
      data['totalColumns'] = headers.length;
      data['createdAt'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = _firestore.collection(collection).doc((nextId + i).toString());
      batch.set(docRef, data);
    }
    
    await batch.commit();
    await updateLastId(collection, nextId + dataList.length - 1);
  }

  // Method untuk add single data dengan ID angka
  Future<void> addDataWithId(String collection, int id, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(id.toString()).set(data);
  }

  // Method untuk get data by ID
  Future<DocumentSnapshot?> getById(String collection, int id) async {
    try {
      return await _firestore.collection(collection).doc(id.toString()).get();
    } catch (e) {
      print("Error getting document by ID: $e");
      return null;
    }
  }

  // Method untuk update data by ID
  Future<void> updateById(String collection, int id, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(collection).doc(id.toString()).update(data);
    } catch (e) {
      print("Error updating document by ID: $e");
    }
  }

  // Method untuk delete data by ID
  Future<void> deleteById(String collection, int id) async {
    try {
      await _firestore.collection(collection).doc(id.toString()).delete();
    } catch (e) {
      print("Error deleting document by ID: $e");
    }
  }

  // Method untuk clear collection dan reset counter
  Future<void> clearCollection(String collection) async {
    final batch = _firestore.batch();
    final snapshots = await _firestore.collection(collection).get();
    
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    
    // Reset counter
    batch.set(_firestore.collection('counters').doc(collection), {
      'lastId': 0,
      'resetAt': FieldValue.serverTimestamp(),
    });
    
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

  // Method untuk get semua data dengan pagination
  Future<List<QueryDocumentSnapshot>> getAllDataPaginated(
    String collection, 
    {int limit = 50, DocumentSnapshot? startAfter}
  ) async {
    Query query = _firestore
        .collection(collection)
        .orderBy('uniqueId')
        .limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    final snapshot = await query.get();
    return snapshot.docs;
  }

  // Method untuk get total count
  Future<int> getTotalCount(String collection) async {
    try {
      DocumentSnapshot counterDoc = await _firestore
          .collection('counters')
          .doc(collection)
          .get();

      if (counterDoc.exists) {
        final data = counterDoc.data() as Map<String, dynamic>;
        return data['lastId'] ?? 0;
      }
      return 0;
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
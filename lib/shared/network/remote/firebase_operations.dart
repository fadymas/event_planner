import 'package:cloud_firestore/cloud_firestore.dart';

late FirebaseFirestore _firestore = FirebaseFirestore.instance;

Stream<List<T>> getData<T>(
  String collectionName,
  T Function(Map<String, dynamic>, String) fromFirestore, {
  Query Function(Query)? queryBuilder,
}) {
  Query collectionRef = _firestore.collection(collectionName);

  if (queryBuilder != null) {
    collectionRef = queryBuilder(collectionRef);
  }

  return collectionRef.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        return fromFirestore({}, doc.id);
      }
      return fromFirestore(data, doc.id);
    }).toList();
  });
}

Future<T?> getDocument<T>(
  String collectionName,
  String documentId,
  T Function(Map<String, dynamic>, String) fromFirestore,
) async {
  try {
    final doc =
        await _firestore.collection(collectionName).doc(documentId).get();
    if (doc.exists) {
      return fromFirestore(doc.data()!, doc.id);
    }
    return null;
  } catch (e) {
    print('Error getting document: $e');
    return null;
  }
}

Future<String> createDocument<T>(
  String collectionName,
  Map<String, dynamic> data,
) async {
  try {
    final docRef = await _firestore.collection(collectionName).add(data);
    return docRef.id;
  } catch (e) {
    print('Error creating document: $e');
    rethrow;
  }
}

Future<void> updateDocument(
  String collectionName,
  String documentId,
  Map<String, dynamic> data,
) async {
  try {
    await _firestore.collection(collectionName).doc(documentId).update(data);
  } catch (e) {
    print('Error updating document: $e');
    rethrow;
  }
}

Future<void> deleteDocument(String collectionName, String documentId) async {
  try {
    await _firestore.collection(collectionName).doc(documentId).delete();
  } catch (e) {
    print('Error deleting document: $e');
    rethrow;
  }
}

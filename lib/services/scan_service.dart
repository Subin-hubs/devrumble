import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> saveScan({
    required String imageBase64,
    required Map<String, dynamic> analysis,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .add({
      'imageBase64': imageBase64,
      'analysis': analysis,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getScans() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
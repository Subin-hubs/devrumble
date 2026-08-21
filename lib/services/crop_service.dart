import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'image_service.dart';

class CropService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<String> uploadCropImage({
    required File imageFile,
    String? userId,
  }) async {

    final String base64Image =
    await ImageService.convertToBase64(imageFile);


    final DocumentReference doc =
    await _firestore.collection('crop_scans').add({
      'imageBase64': base64Image,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId,
      'status': 'uploaded',
    });

    return doc.id;
  }
}
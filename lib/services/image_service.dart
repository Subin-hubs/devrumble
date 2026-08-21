import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImageService {
  static Future<String> convertToBase64(File file) async {

    final Uint8List originalBytes = await file.readAsBytes();

    // Decode image
    final img.Image? originalImage =
    img.decodeImage(originalBytes);

    if (originalImage == null) {
      throw Exception('Could not read image');
    }

    img.Image resizedImage = originalImage;

    const int maxWidth = 1000;

    if (originalImage.width > maxWidth) {
      resizedImage = img.copyResize(
        originalImage,
        width: maxWidth,
      );
    }

    final List<int> compressedBytes = img.encodeJpg(
      resizedImage,
      quality: 70,
    );

    return base64Encode(compressedBytes);
  }
}
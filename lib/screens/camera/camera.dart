import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'analysis_result_screen.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  static const Color darkGreen = Color(0xFF14432A);
  static const Color midGreen = Color(0xFF2E7D4F);
  static const Color paleGreenBg = Color(0xFFEFF5EC);
  static const Color checkGreen = Color(0xFF3E8E5A);

  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String apiUrl = 'http://10.120.8.144:8080/analyze';

  File? selectedImage;
  bool isSaving = false;
  bool isAnalyzing = false;

  Map<String, dynamic>? analysisResult;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (picked == null) return;

      setState(() {
        selectedImage = File(picked.path);
        analysisResult = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not get photo: $e'),
        ),
      );
    }
  }

  Future<String> _convertToBase64(File file) async {
    final bytes = await file.readAsBytes();

    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Could not process image');
    }

    final resized = image.width > 1000
        ? img.copyResize(
      image,
      width: 1000,
    )
        : image;

    final compressed = img.encodeJpg(
      resized,
      quality: 70,
    );

    return base64Encode(compressed);
  }

  Future<Map<String, dynamic>> _analyzeImage(
      String base64Image,
      ) async {
    final response = await http
        .post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'imageBase64': base64Image,
      }),
    )
        .timeout(
      const Duration(seconds: 60),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'AI server error ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid AI response');
    }

    return data;
  }

  Future<void> _saveImageToFirebase() async {
    if (selectedImage == null || isSaving || isAnalyzing) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User is not logged in'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final String base64Image =
      await _convertToBase64(selectedImage!);

      final DocumentReference document =
      await _firestore.collection('crop_scans').add({
        'uid': user.uid,
        'imageBase64': base64Image,
        'status': 'analyzing',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isSaving = false;
        isAnalyzing = true;
      });

      final result = await _analyzeImage(base64Image);

      await document.update({
        'status': 'analyzed',
        'analysis': result,
        'analyzedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isAnalyzing = false;
        selectedImage = null;
        analysisResult = result;
      });

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultScreen(
            result: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
        isAnalyzing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
        ),
      );
    }
  }

  void _clearImage() {
    if (isSaving || isAnalyzing) return;

    setState(() {
      selectedImage = null;
      analysisResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPhotoCaptureCard(),
                    if (analysisResult != null)
                      _buildAnalysisResult(),
                    _buildPhotoTipsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCaptureCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: paleGreenBg,
            image: selectedImage == null
                ? const DecorationImage(
              image: AssetImage('assets/img.png'),
              fit: BoxFit.cover,
              opacity: 0.35,
            )
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 36,
            horizontal: 20,
          ),
          child: selectedImage == null
              ? _buildEmptyCaptureState()
              : _buildSelectedImageState(),
        ),
      ),
    );
  }

  Widget _buildEmptyCaptureState() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            size: 32,
            color: darkGreen,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Take a clear photo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Focus on the affected leaf or plant area for best AI results',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        _buildCaptureButtons(),
      ],
    );
  }

  Widget _buildSelectedImageState() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            selectedImage!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSaving || isAnalyzing
                    ? null
                    : _clearImage,
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                ),
                label: const Text('Retake'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: midGreen,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  side: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isSaving || isAnalyzing
                    ? null
                    : _saveImageToFirebase,
                icon: isSaving || isAnalyzing
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.check,
                  size: 20,
                ),
                label: Text(
                  isSaving
                      ? 'Saving...'
                      : isAnalyzing
                      ? 'Analyzing...'
                      : 'Analyze',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: midGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  midGreen.withOpacity(0.6),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCaptureButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isAnalyzing || isSaving
                ? null
                : () => _pickImage(ImageSource.camera),
            icon: const Icon(
              Icons.camera_alt,
              size: 20,
            ),
            label: const Text('Camera'),
            style: ElevatedButton.styleFrom(
              backgroundColor: midGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isAnalyzing || isSaving
                ? null
                : () => _pickImage(ImageSource.gallery),
            icon: const Icon(
              Icons.upload_outlined,
              size: 20,
            ),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: midGreen,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              side: BorderSide(
                color: Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisResult() {
    final Map<String, dynamic> result = analysisResult!;

    final String crop =
        result['crop']?.toString() ?? 'Unknown';

    final String condition =
        result['condition']?.toString() ?? 'Unknown';

    final String confidence =
        result['confidence']?.toString() ?? '0';

    final String severity =
        result['severity']?.toString() ?? 'Unknown';

    final String description =
        result['description']?.toString() ?? '';

    final List<String> recommendations =
    result['recommendations'] is List
        ? List<String>.from(
      result['recommendations'],
    )
        : <String>[];

    final List<String> prevention =
    result['prevention'] is List
        ? List<String>.from(
      result['prevention'],
    )
        : <String>[];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: paleGreenBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Diagnosis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 18),
          _buildResultRow('Crop', crop),
          _buildResultRow('Condition', condition),
          _buildResultRow('Confidence', '$confidence%'),
          _buildResultRow('Severity', severity),
          const SizedBox(height: 14),
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...recommendations.map(
                  (item) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: checkGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (prevention.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Prevention',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...prevention.map(
                  (item) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: midGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTipsCard() {
    const List<String> tips = [
      'Natural daylight gives the best results',
      'Hold camera 20-30 cm from the plant',
      'Capture the most visibly affected part',
      'Avoid blurry, shadowed, or overexposed shots',
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.fromLTRB(
        20,
        24,
        20,
        28,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: Color(0xFFB5651D),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Photo tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map(
                (tip) => Padding(
              padding: const EdgeInsets.only(
                bottom: 14,
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: checkGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
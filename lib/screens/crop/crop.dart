
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../camera/history.dart';
import '../home/home.dart';

class Crop extends StatelessWidget {
  const Crop({super.key});

  void _openScanHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScanHistoryScreen(),
      ),
    );
  }

  void _openCropDetails(
      BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> scan,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CropDetailsScreen(scan: scan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('crop_scans')
          .where('uid', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.accentGreen,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Your Crops',
                  subtitle: 'तपाईंका बाली',
                  trailing: 'View History',
                  onTrailingTap: () => _openScanHistory(context),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Unable to load your crop scans.',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final scans = List<
            QueryDocumentSnapshot<Map<String, dynamic>>>.from(
          snapshot.data?.docs ?? [],
        );

        scans.sort((a, b) {
          final aTime = a.data()['createdAt'];
          final bTime = b.data()['createdAt'];

          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }

          if (aTime is Timestamp) {
            return -1;
          }

          if (bTime is Timestamp) {
            return 1;
          }

          return 0;
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ),
              child: SectionHeader(
                title: 'Your Crops',
                subtitle: 'तपाईंका बाली',
                trailing: 'View History',
                onTrailingTap: () => _openScanHistory(context),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.86,
              ),
              itemCount: scans.isEmpty ? 2 : scans.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _AddCropGridCard(
                    onTap: () => _openScanHistory(context),
                  );
                }

                if (scans.isEmpty) {
                  return _EmptyCropCard(
                    onTap: () => _openScanHistory(context),
                  );
                }

                final scan = scans[index - 1];
                final data = scan.data();

                final imageBase64 =
                    data['imageBase64']?.toString() ?? '';

                final analysis = data['analysis'] is Map
                    ? Map<String, dynamic>.from(data['analysis'])
                    : <String, dynamic>{};

                final crop = _findValue(
                  analysis,
                  data,
                  [
                    'crop',
                    'cropName',
                    'plant',
                    'plantName',
                    'crop_type',
                    'cropType',
                  ],
                  'Crop Analysis',
                );

                final condition = _findValue(
                  analysis,
                  data,
                  [
                    'condition',
                    'disease',
                    'health',
                    'status',
                    'diagnosis',
                  ],
                  'Analyzed',
                );

                final confidence = _getConfidence(
                  analysis,
                  data,
                );

                return CropScanCard(
                  imageBase64: imageBase64,
                  crop: crop,
                  condition: condition,
                  confidence: confidence,
                  onTap: () => _openCropDetails(
                    context,
                    scan,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  static String _findValue(
      Map<String, dynamic> analysis,
      Map<String, dynamic> data,
      List<String> keys,
      String fallback,
      ) {
    for (final key in keys) {
      final analysisValue = analysis[key];

      if (analysisValue != null &&
          analysisValue.toString().trim().isNotEmpty) {
        return analysisValue.toString().trim();
      }

      final dataValue = data[key];

      if (dataValue != null &&
          dataValue.toString().trim().isNotEmpty) {
        return dataValue.toString().trim();
      }
    }

    return fallback;
  }

  static String _getConfidence(
      Map<String, dynamic> analysis,
      Map<String, dynamic> data,
      ) {
    dynamic value = analysis['confidence'];

    value ??= analysis['confidenceScore'];
    value ??= analysis['probability'];
    value ??= data['confidence'];

    if (value == null) {
      return '';
    }

    try {
      final number = double.parse(value.toString());

      if (number <= 1) {
        return '${(number * 100).toStringAsFixed(0)}%';
      }

      return '${number.toStringAsFixed(0)}%';
    } catch (_) {
      return value.toString();
    }
  }
}

class _AddCropGridCard extends StatelessWidget {
  const _AddCropGridCard({
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEFEAE0),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.darkGreen,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add Crop',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'बाली थप्नुहोस्',
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCropCard extends StatelessWidget {
  const _EmptyCropCard({
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: const BoxDecoration(
                  color: AppColors.scanBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: AppColors.accentGreen,
                  size: 25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'No scans yet',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Scan a crop to see it here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 9.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CropScanCard extends StatelessWidget {
  const CropScanCard({
    super.key,
    required this.imageBase64,
    required this.crop,
    required this.condition,
    this.confidence = '',
    this.onTap,
  });

  final String imageBase64;
  final String crop;
  final String condition;
  final String confidence;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes;

    if (imageBase64.isNotEmpty) {
      try {
        imageBytes = base64Decode(imageBase64);
      } catch (_) {
        imageBytes = null;
      }
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageBytes != null)
              Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _imagePlaceholder();
                },
              )
            else
              _imagePlaceholder(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.88),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.touch_app_outlined,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
            if (confidence.isNotEmpty)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    confidence,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 11,
              right: 11,
              bottom: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    condition,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.scanBg,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.accentGreen,
          size: 38,
        ),
      ),
    );
  }
}

class CropDetailsScreen extends StatelessWidget {
  const CropDetailsScreen({
    super.key,
    required this.scan,
  });

  final DocumentSnapshot<Map<String, dynamic>> scan;

  @override
  Widget build(BuildContext context) {
    final data = scan.data() ?? {};

    final analysis = data['analysis'] is Map
        ? Map<String, dynamic>.from(data['analysis'])
        : <String, dynamic>{};

    final imageBase64 =
        data['imageBase64']?.toString() ?? '';

    final crop = Crop._findValue(
      analysis,
      data,
      [
        'crop',
        'cropName',
        'plant',
        'plantName',
        'crop_type',
        'cropType',
      ],
      'Crop Analysis',
    );

    final condition = Crop._findValue(
      analysis,
      data,
      [
        'condition',
        'disease',
        'health',
        'status',
        'diagnosis',
      ],
      'Analyzed',
    );

    final confidence = Crop._getConfidence(
      analysis,
      data,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Crop Analysis',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailsImage(
              imageBase64: imageBase64,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    condition,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.health_and_safety_outlined,
                          title: 'Condition',
                          value: condition,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.analytics_outlined,
                          title: 'Confidence',
                          value: confidence.isEmpty
                              ? 'N/A'
                              : confidence,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Analysis Details',
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (analysis.isNotEmpty)
                    ...analysis.entries.map(
                          (entry) => _DataTile(
                        title: _formatKey(entry.key),
                        value: _formatValue(entry.value),
                      ),
                    ),
                  const SizedBox(height: 15),
                  Text(
                    'Scan Information',
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...data.entries
                      .where(
                        (entry) =>
                    entry.key != 'analysis' &&
                        entry.key != 'imageBase64',
                  )
                      .map(
                        (entry) => _DataTile(
                      title: _formatKey(entry.key),
                      value: _formatValue(entry.value),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatKey(String key) {
    final result = key
        .replaceAll('_', ' ')
        .replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
          (match) =>
      '${match.group(1)} ${match.group(2)}',
    );

    return result
        .split(' ')
        .map(
          (word) => word.isEmpty
          ? word
          : word[0].toUpperCase() +
          word.substring(1),
    )
        .join(' ');
  }

  static String _formatValue(dynamic value) {
    if (value == null) {
      return 'N/A';
    }

    if (value is Timestamp) {
      return value.toDate().toString();
    }

    if (value is List) {
      return value.map(_formatValue).join(', ');
    }

    if (value is Map) {
      return value.entries
          .map(
            (e) =>
        '${_formatKey(e.key.toString())}: '
            '${_formatValue(e.value)}',
      )
          .join('\n');
    }

    return value.toString();
  }
}

class _DetailsImage extends StatelessWidget {
  const _DetailsImage({
    required this.imageBase64,
  });

  final String imageBase64;

  @override
  Widget build(BuildContext context) {
    if (imageBase64.isEmpty) {
      return Container(
        width: double.infinity,
        height: 280,
        color: AppColors.scanBg,
        child: const Icon(
          Icons.image_outlined,
          size: 70,
          color: AppColors.accentGreen,
        ),
      );
    }

    try {
      final bytes = base64Decode(imageBase64);

      return SizedBox(
        width: double.infinity,
        height: 300,
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: AppColors.scanBg,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 60,
                color: AppColors.accentGreen,
              ),
            );
          },
        ),
      );
    } catch (_) {
      return Container(
        width: double.infinity,
        height: 280,
        color: AppColors.scanBg,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 60,
          color: AppColors.accentGreen,
        ),
      );
    }
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.accentGreen,
            size: 24,
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataTile extends StatelessWidget {
  const _DataTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentGreen,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}


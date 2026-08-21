import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  static const Color background = Color(0xFFF5F1E8);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color accentGreen = Color(0xFF2E7D5B);
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: darkGreen,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan History',
          style: GoogleFonts.poppins(
            color: darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('scans')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: accentGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load scan history.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }

          final scans = snapshot.data?.docs ?? [];

          if (scans.isEmpty) {
            return _EmptyHistory();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              30,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: scans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final scan = scans[index].data();

              return _ScanCard(
                data: scan,
                onTap: () {
                  _openScanDetails(
                    context,
                    scan,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _openScanDetails(
      BuildContext context,
      Map<String, dynamic> scan,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScanDetailsScreen(
          scan: scan,
        ),
      ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard({
    required this.data,
    required this.onTap,
  });

  final Map<String, dynamic> data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cropName =
        data['cropName']?.toString() ?? 'Unknown Crop';

    final disease =
        data['disease']?.toString() ?? 'Unknown';

    final status =
        data['status']?.toString() ?? 'Unknown';

    final confidence =
        data['confidence']?.toString() ?? '0';

    final imageUrl =
    data['imageUrl']?.toString();

    final createdAt = data['createdAt'];

    String dateText = 'Recently';

    if (createdAt is Timestamp) {
      final date = createdAt.toDate();

      dateText =
      '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _ScanImage(
                imageUrl: imageUrl,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      cropName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color:
                        ScanHistoryScreen.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      disease,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color:
                        ScanHistoryScreen.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatusBadge(
                          status: status,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$confidence%',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color:
                            ScanHistoryScreen.accentGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dateText,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color:
                        ScanHistoryScreen.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: ScanHistoryScreen.darkGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanImage extends StatelessWidget {
  const _ScanImage({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: 90,
        height: 105,
        child: imageUrl != null &&
            imageUrl!.isNotEmpty
            ? Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _placeholder();
          },
        )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE3F1E6),
      child: const Icon(
        Icons.eco_outlined,
        color: ScanHistoryScreen.accentGreen,
        size: 32,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    Color color;

    if (normalized.contains('healthy')) {
      color = const Color(0xFF2E7D5B);
    } else if (normalized.contains('moderate') ||
        normalized.contains('monitor') ||
        normalized.contains('warning')) {
      color = const Color(0xFFD98A2C);
    } else if (normalized.contains('severe') ||
        normalized.contains('critical')) {
      color = const Color(0xFFC94C4C);
    } else {
      color = ScanHistoryScreen.accentGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFE3F1E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                size: 42,
                color: ScanHistoryScreen.accentGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No scans yet',
              style: GoogleFonts.poppins(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: ScanHistoryScreen.darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your crop analysis history will appear here after you scan a crop.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: ScanHistoryScreen.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanDetailsScreen extends StatelessWidget {
  const ScanDetailsScreen({
    super.key,
    required this.scan,
  });

  final Map<String, dynamic> scan;

  @override
  Widget build(BuildContext context) {
    final crop =
        scan['cropName']?.toString() ?? 'Unknown';

    final disease =
        scan['disease']?.toString() ?? 'Unknown';

    final status =
        scan['status']?.toString() ?? 'Unknown';

    final confidence =
        scan['confidence']?.toString() ?? '0';

    final recommendation =
        scan['recommendation']?.toString() ?? '';

    final imageUrl =
    scan['imageUrl']?.toString();

    return Scaffold(
      backgroundColor:
      ScanHistoryScreen.background,
      appBar: AppBar(
        backgroundColor:
        ScanHistoryScreen.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: ScanHistoryScreen.darkGreen,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan Result',
          style: GoogleFonts.poppins(
            color: ScanHistoryScreen.darkGreen,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          30,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            if (imageUrl != null &&
                imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius:
                BorderRadius.circular(22),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 230,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const SizedBox();
                  },
                ),
              ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Diagnosis',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color:
                      ScanHistoryScreen.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _DetailRow(
                    title: 'Crop',
                    value: crop,
                  ),
                  _DetailRow(
                    title: 'Disease',
                    value: disease,
                  ),
                  _DetailRow(
                    title: 'Status',
                    value: status,
                  ),
                  _DetailRow(
                    title: 'Confidence',
                    value: '$confidence%',
                  ),
                  if (recommendation.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    Text(
                      'Recommendation',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      recommendation,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color:
                        ScanHistoryScreen.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color:
                ScanHistoryScreen.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                ScanHistoryScreen.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
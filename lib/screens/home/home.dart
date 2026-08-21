import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dev_rumble/navbar.dart';
import 'package:dev_rumble/screens/home/weather/weather.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../camera/history.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF5F1E8);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color darkGreenLight = Color(0xFF265C43);
  static const Color accentGreen = Color(0xFF2E7D5B);

  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF6B6B6B);

  static const Color scanBg = Color(0xFFE3F1E6);
  static const Color scanIcon = Color(0xFF2E7D5B);

  static const Color weatherBg = Color(0xFFE2ECF9);
  static const Color weatherIcon = Color(0xFF3B72C4);

  static const Color marketBg = Color(0xFFFBEBD3);
  static const Color marketIcon = Color(0xFFC9832A);

  static const Color calendarBg = Color(0xFFEAE3F7);
  static const Color calendarIcon = Color(0xFF7C57C9);

  static const Color weatherCardStart = Color(0xFF2D5FA3);
  static const Color weatherCardEnd = Color(0xFF23477E);

  static const Color healthy = Color(0xFF2E7D5B);
  static const Color warning = Color(0xFFD98A2C);
}

class AppSpacing {
  AppSpacing._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> colored(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
}

class Home extends StatelessWidget {
  const Home({super.key});

  void _openCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Navbar(2, true),
      ),
    );
  }

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accentGreen,
                ),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Unable to load your profile.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }

            final data = snapshot.data?.data() ?? {};

            final String name =
            data['name']?.toString().trim().isNotEmpty == true
                ? data['name'].toString()
                : 'Farmer';

            final String location =
            data['location']?.toString().trim().isNotEmpty == true
                ? data['location'].toString()
                : 'Location not set';

            final String? profileImage =
            data['profileImage']?.toString().trim().isNotEmpty == true
                ? data['profileImage'].toString()
                : null;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    name: name,
                    location: location,
                    profileImage: profileImage,
                    onScanTap: () => _openCamera(context),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _QuickActionsSection(
                          onScanTap: () => _openCamera(context),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const _WeatherCard(),
                        const SizedBox(height: AppSpacing.xxl),
                        const _CropsSection(),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.location,
    required this.profileImage,
    required this.onScanTap,
  });

  final String name;
  final String location;
  final String? profileImage;
  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        35,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkGreen,
            AppColors.darkGreenLight,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -25,
            child: Icon(
              Icons.eco,
              size: 130,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          Positioned(
            left: -35,
            bottom: -45,
            child: Icon(
              Icons.grass,
              size: 110,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NAMASTE 🙏',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: Colors.white70,
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ProfileAvatar(
                    imageUrl: profileImage,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _AiScanCard(
                onTap: onScanTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const ColoredBox(
              color: Colors.white,
              child: Icon(
                Icons.person,
                color: AppColors.accentGreen,
                size: 27,
              ),
            );
          },
        )
            : const ColoredBox(
          color: Colors.white,
          child: Icon(
            Icons.person,
            color: AppColors.accentGreen,
            size: 27,
          ),
        ),
      ),
    );
  }
}

class _AiScanCard extends StatelessWidget {
  const _AiScanCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accentGreen,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppShadows.colored(
          AppColors.darkGreen,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -15,
            child: Icon(
              Icons.eco,
              color: Colors.white.withOpacity(0.12),
              size: 85,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  'AI CROP ANALYSIS',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Is your crop healthy?',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Take a photo and let AI check your crop for\n'
                    'diseases, pests and nutrient problems.',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 11.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 11,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          size: 18,
                          color: AppColors.darkGreen,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Scan Crop',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({
    required this.onScanTap,
  });

  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const SectionHeader(
            title: 'Quick Actions',
            subtitle: 'द्रुत कार्यहरू',
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  label: 'Scan',
                  subLabel: 'स्क्यान',
                  icon: Icons.eco_outlined,
                  background: AppColors.scanBg,
                  iconColor: AppColors.scanIcon,
                  onTap: onScanTap,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: QuickActionButton(
                  label: 'Weather',
                  subLabel: 'मौसम',
                  icon: Icons.cloud_outlined,
                  background: AppColors.weatherBg,
                  iconColor: AppColors.weatherIcon,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: QuickActionButton(
                  label: 'Market',
                  subLabel: 'बजार',
                  icon: Icons.storefront_outlined,
                  background: AppColors.marketBg,
                  iconColor: AppColors.marketIcon,
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Navbar(3, true),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: QuickActionButton(
                  label: 'Crop',
                  subLabel: 'बाली',
                  icon: Icons.eco_outlined,
                  background: AppColors.calendarBg,
                  iconColor: AppColors.calendarIcon,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
      ),
      child: FutureBuilder<WeatherData>(
        future: WeatherService.getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.weatherCardStart,
                    AppColors.weatherCardEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'Loading weather...',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.weatherCardStart,
                    AppColors.weatherCardEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text(
                    '🌦️',
                    style: TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Unable to load weather',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Home(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final weather = snapshot.data!;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.weatherCardStart,
                  AppColors.weatherCardEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.colored(
                AppColors.weatherCardEnd,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    weather.weatherIcon,
                    style: const TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kathmandu',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Row(
                        children: [
                          Text(
                            '${weather.temperature.round()}°C',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: Text(
                              weather.condition,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${weather.humidity}%',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Humidity',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CropsSection extends StatelessWidget {
  const _CropsSection();

  void _openScanHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScanHistoryScreen(),
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
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
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
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          );
        }

        final scans = snapshot.data?.docs ?? [];

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
                onTrailingTap: () => _openScanHistory(context),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                ),
                itemCount: scans.isEmpty ? 2 : scans.length + 1,
                separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return AddCropCard(
                      onTap: () => _openScanHistory(context),
                    );
                  }

                  if (scans.isEmpty) {
                    return _EmptyCropCard(
                      onTap: () => _openScanHistory(context),
                    );
                  }

                  final data = scans[index - 1].data();

                  final String imageBase64 =
                      data['imageBase64']?.toString() ?? '';

                  final Map<String, dynamic> analysis =
                  data['analysis'] is Map
                      ? Map<String, dynamic>.from(
                    data['analysis'],
                  )
                      : {};

                  final String crop =
                      analysis['crop']?.toString() ??
                          analysis['cropName']?.toString() ??
                          data['crop']?.toString() ??
                          data['cropName']?.toString() ??
                          'Unknown Crop';

                  final String condition =
                      analysis['condition']?.toString() ??
                          analysis['disease']?.toString() ??
                          data['condition']?.toString() ??
                          data['disease']?.toString() ??
                          'Unknown Condition';

                  return CropScanCard(
                    imageBase64: imageBase64,
                    crop: crop,
                    condition: condition,
                    onTap: () => _openScanHistory(context),
                  );
                },
              ),
            ),
          ],
        );
      },
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
    return SizedBox(
      width: 190,
      height: 132,
      child: Material(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.history,
                  color: AppColors.accentGreen,
                  size: 25,
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan History',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'View your previous crop analysis.',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTrailingTap,
  });

  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        if (trailing != null)
          TextButton(
            onPressed: onTrailingTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize:
              MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: [
                Text(
                  trailing!,
                  style: GoogleFonts.poppins(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: AppColors.darkGreen,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.background,
    required this.iconColor,
    this.onTap,
  });

  final String label;
  final String subLabel;
  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.65),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 19,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subLabel,
                style: GoogleFonts.poppins(
                  fontSize: 9,
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

class AddCropCard extends StatelessWidget {
  const AddCropCard({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 132,
      child: Material(
        color: const Color(0xFFEFEAE0),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.darkGreen,
                  size: 21,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add Crop',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'बाली थप्नुहोस्',
                style: GoogleFonts.poppins(
                  fontSize: 9,
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
    this.onTap,
  });

  final String imageBase64;
  final String crop;
  final String condition;
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

    return SizedBox(
      width: 165,
      height: 132,
      child: Material(
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
                    return Container(
                      color: AppColors.scanBg,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.accentGreen,
                        size: 30,
                      ),
                    );
                  },
                )
              else
                Container(
                  color: AppColors.scanBg,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.accentGreen,
                    size: 30,
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.78),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 9,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      condition,
                      maxLines: 1,
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
      ),
    );
  }
}
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/login_screen.dart';
import '../camera/history.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  static const darkGreen = Color(0xFF2F4319);
  static const bg = Color(0xFFFBF9F4);
  static const accentGreen = Color(0xFF1B5E20);

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Profile.darkGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to logout. Please try again.'),
        ),
      );
    }
  }


  void _openHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScanHistoryScreen(),
      ),
    );
  }

  void _showPersonalInformation(
      BuildContext context,
      Map<String, dynamic> data,
      User user,
      ) {
    final name = _getString(
      data,
      'name',
      fallback: user.displayName ?? 'Farmer',
    );

    final email = _getString(
      data,
      'email',
      fallback: user.email ?? 'Not available',
    );

    final phone = _getString(
      data,
      'phone',
      fallback: 'Not available',
    );

    final location = _getString(
      data,
      'location',
      fallback: 'Not set',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Personal Information',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 18),
                _InfoRow(
                  icon: Icons.person_outline,
                  title: 'Name',
                  value: name,
                ),
                _InfoRow(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: email,
                ),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  title: 'Phone',
                  value: phone,
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  value: location,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Agrova',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: darkGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.eco,
          color: Colors.white,
        ),
      ),
      children: [
        Text(
          'Agrova is an agricultural platform designed to help farmers with crop analysis, weather information, market prices and other useful farming tools.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              15,
              20,
              30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2E4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.headset_mic_outlined,
                    color: darkGreen,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Help & Support',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Need help with Agrova? Contact our support team for assistance.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        color: darkGreen,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'support@agrova.com',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _getString(
      Map<String, dynamic> data,
      String key, {
        String fallback = '',
      }) {
    final value = data[key];

    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        top: false,
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: darkGreen,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 45,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Unable to load profile',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data?.data() ?? {};

            final name = _getString(
              data,
              'name',
              fallback: user.displayName ?? 'Farmer',
            );

            final email = _getString(
              data,
              'email',
              fallback: user.email ?? 'Email not available',
            );

            final phone = _getString(
              data,
              'phone',
              fallback: 'Phone not available',
            );

            final profileImage = _getString(
              data,
              'profileImage',
            );

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHero(),
                  _buildAvatar(profileImage),
                  const SizedBox(height: 12),
                  _buildNameAndContact(
                    name: name,
                    email: email,
                    phone: phone,
                  ),
                  const SizedBox(height: 12),
                  _buildDivider(),
                  const SizedBox(height: 8),
                  _buildMenu(
                    context,
                    data,
                    user,
                  ),
                  const SizedBox(height: 12),
                  _buildLogoutButton(context),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF3D9A4),
                  Color(0xFFE7B98A),
                  Color(0xFFC9A15E),
                  Color(0xFF8A9B4E),
                  Color(0xFF5C7A38),
                  Color(0xFF3F5C28),
                ],
                stops: [
                  0.0,
                  0.22,
                  0.40,
                  0.55,
                  0.75,
                  1.0,
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 30,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow.shade100
                    .withOpacity(0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.shade100
                        .withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 90,
              child: CustomPaint(
                painter: _FieldRowsPainter(),
                size: const Size(
                  double.infinity,
                  90,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: darkGreen,
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String image) {
    return Transform.translate(
      offset: const Offset(0, -56),
      child: Center(
        child: Stack(
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildProfileImage(image),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentGreen,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String image) {
    if (image.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3E6B3A),
              Color(0xFF1E3A1B),
            ],
          ),
        ),
        child: const Icon(
          Icons.person,
          size: 56,
          color: Colors.white70,
        ),
      );
    }

    if (image.startsWith('http')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _defaultAvatar();
        },
      );
    }

    try {
      final Uint8List bytes = base64Decode(image);

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _defaultAvatar();
        },
      );
    } catch (_) {
      return _defaultAvatar();
    }
  }

  Widget _defaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3E6B3A),
            Color(0xFF1E3A1B),
          ],
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 56,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildNameAndContact({
    required String name,
    required String email,
    required String phone,
  }) {
    return Transform.translate(
      offset: const Offset(0, -44),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: darkGreen,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.verified,
                size: 18,
                color: accentGreen,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          if (phone != 'Phone not available') ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  phone,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Transform.translate(
      offset: const Offset(0, -36),
      child: Center(
        child: SizedBox(
          width: 96,
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.eco,
                size: 14,
                color: accentGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(
      BuildContext context,
      Map<String, dynamic> data,
      User user,
      ) {
    final items = <_MenuItemData>[
      _MenuItemData(
        Icons.person_outline,
        'Personal Information',
            () => _showPersonalInformation(
          context,
          data,
          user,
        ),
      ),
      _MenuItemData(
        Icons.history_outlined,
        'Scan History',
            () => _openHistory(context),
      ),
      _MenuItemData(
        Icons.headset_mic_outlined,
        'Help & Support',
            () => _showHelp(context),
      ),
      _MenuItemData(
        Icons.info_outline,
        'About Agrova',
            () => _showAbout(context),
      ),
    ];

    return Transform.translate(
      offset: const Offset(0, -24),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: List.generate(
              items.length,
                  (i) {
                final item = items[i];
                final isLast = i == items.length - 1;

                return InkWell(
                  onTap: item.onTap,
                  borderRadius: isLast
                      ? const BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  )
                      : BorderRadius.zero,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F2E4),
                            borderRadius:
                            BorderRadius.circular(11),
                          ),
                          child: Icon(
                            item.icon,
                            size: 20,
                            color: darkGreen,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Text(
                            item.label,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 19,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
            onTap: () => _logout(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 18,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: const Color(0xFFF3CCCC),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDCDC),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 19,
                    color: Colors.redAccent.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItemData(
      this.icon,
      this.label,
      this.onTap,
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2E4),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: Profile.darkGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldRowsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3F5C28)
          .withOpacity(0.5)
      ..strokeWidth = 3;

    const spacing = 16.0;
    final diagonal = size.width + size.height;

    for (
    double x = -size.height;
    x < diagonal;
    x += spacing
    ) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  static const Color darkGreen = Color(0xFF14361F);
  static const Color mediumGreen = Color(0xFF3E7B27);
  static const Color hintGrey = Color(0xFF8A8A85);
  static const Color fieldBorder = Color(0xFFE0E0DA);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;

  String _name = 'Loading...';
  String _email = '';
  String _phone = '';
  String? _avatarUrl;

  int _farms = 0;
  int _crops = 0;
  double _yieldKg = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ============================================================
  // LOAD USER DATA
  // ============================================================

  Future<void> _loadUserData() async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        debugPrint('NO USER LOGGED IN');

        if (mounted) {
          setState(() {
            _isLoading = false;
            _name = 'Guest';
            _email = '';
          });
        }

        return;
      }

      debugPrint('CURRENT USER UID: ${user.uid}');

      final DocumentSnapshot<Map<String, dynamic>> document =
      await _firestore.collection('users').doc(user.uid).get();

      if (!document.exists) {
        debugPrint('USER DOCUMENT DOES NOT EXIST');

        if (mounted) {
          setState(() {
            _isLoading = false;
            _name = user.displayName ?? 'User';
            _email = user.email ?? '';
          });
        }

        return;
      }

      final data = document.data()!;

      debugPrint('USER DATA: $data');

      if (!mounted) return;

      setState(() {
        _name = data['fullName']?.toString() ??
            user.displayName ??
            'User';

        _email = data['email']?.toString() ??
            user.email ??
            '';

        _phone = data['phone']?.toString() ?? '';

        _avatarUrl = data['avatarUrl']?.toString();

        _farms = _toInt(data['farms']);
        _crops = _toInt(data['crops']);
        _yieldKg = _toDouble(data['yieldKg']);

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('PROFILE LOAD ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: $e'),
        ),
      );
    }
  }

  // ============================================================
  // SAFE NUMBER CONVERSION
  // ============================================================

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _handleLogout() async {
    try {
      await _auth.signOut();

      if (!mounted) return;

      // Change this to your actual LoginScreen import/navigation.
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    } catch (e) {
      debugPrint('LOGOUT ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
        ),
      );
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refreshProfile() async {
    setState(() {
      _isLoading = true;
    });

    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:

          SafeArea(
            child: Column(
              children: [
                // ==================================================
                // TOP BAR
                // ==================================================

                // ==================================================
                // CONTENT
                // ==================================================

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshProfile,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        height: 500,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: mediumGreen,
                          ),
                        ),
                      )
                          : Column(
                        children: [
                          const SizedBox(height: 8),

                          // ================================
                          // AVATAR
                          // ================================

                          ProfileAvatar(
                            avatarUrl: _avatarUrl,
                            onChangePhoto: () {
                              // TODO:
                              // image picker + Firebase Storage
                            },
                          ),

                          const SizedBox(height: 16),

                          // ================================
                          // NAME
                          // ================================

                          Text(
                            _name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // ================================
                          // EMAIL
                          // ================================

                          Text(
                            _email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: hintGrey,
                            ),
                          ),

                          if (_phone.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _phone,
                              style: const TextStyle(
                                fontSize: 13,
                                color: hintGrey,
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // ================================
                          // STATS
                          // ================================

                          ProfileStatsRow(
                            farms: _farms.toString(),
                            crops: _crops.toString(),
                            yieldKg: _formatYield(_yieldKg),
                          ),

                          const SizedBox(height: 24),

                          // ================================
                          // MENU
                          // ================================

                          ProfileMenuItem(
                            icon: Icons.person_outline,
                            label: 'Account Details',
                            onTap: () {},
                          ),

                          ProfileMenuItem(
                            icon: Icons.agriculture_outlined,
                            label: 'My Farms',
                            onTap: () {},
                          ),

                          ProfileMenuItem(
                            icon: Icons.receipt_long_outlined,
                            label: 'Orders & Transactions',
                            onTap: () {},
                          ),

                          ProfileMenuItem(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            onTap: () {},
                          ),

                          ProfileMenuItem(
                            icon: Icons.settings_outlined,
                            label: 'Settings',
                            onTap: () {},
                          ),

                          ProfileMenuItem(
                            icon: Icons.help_outline,
                            label: 'Help & Support',
                            onTap: () {},
                          ),

                          const SizedBox(height: 8),

                          // ================================
                          // LOGOUT
                          // ================================

                          ProfileMenuItem(
                            icon: Icons.logout,
                            label: 'Log out',
                            iconColor: Colors.redAccent,
                            textColor: Colors.redAccent,
                            onTap: _handleLogout,
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      );

  }

  String _formatYield(double value) {
    if (value == 0) {
      return '0';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }

    return value.toStringAsFixed(
      value % 1 == 0 ? 0 : 1,
    );
  }
}

// ================================================================
// PROFILE AVATAR
// ================================================================

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    required this.onChangePhoto,
  });

  final String? avatarUrl;
  final VoidCallback onChangePhoto;

  static const Color darkGreen = Color(0xFF14361F);
  static const Color mediumGreen = Color(0xFF3E7B27);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: Colors.white,
          backgroundImage:
          avatarUrl != null && avatarUrl!.isNotEmpty
              ? NetworkImage(avatarUrl!)
              : null,
          child: avatarUrl == null || avatarUrl!.isEmpty
              ? const Icon(
            Icons.person,
            size: 56,
            color: mediumGreen,
          )
              : null,
        ),

        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onChangePhoto,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: darkGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// STATS
// ================================================================

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.farms,
    required this.crops,
    required this.yieldKg,
  });

  final String farms;
  final String crops;
  final String yieldKg;

  static const Color fieldBorder = Color(0xFFE0E0DA);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: fieldBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StatItem(
            value: farms,
            label: 'Farms',
          ),
          Container(
            width: 1,
            height: 32,
            color: fieldBorder,
          ),
          StatItem(
            value: crops,
            label: 'Crops',
          ),
          Container(
            width: 1,
            height: 32,
            color: fieldBorder,
          ),
          StatItem(
            value: yieldKg,
            label: 'Yield (kg)',
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  const StatItem({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  static const Color darkGreen = Color(0xFF14361F);
  static const Color hintGrey = Color(0xFF8A8A85);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkGreen,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: hintGrey,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// MENU ITEM
// ================================================================

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  static const Color darkGreen = Color(0xFF14361F);
  static const Color mediumGreen = Color(0xFF3E7B27);
  static const Color hintGrey = Color(0xFF8A8A85);
  static const Color fieldBorder = Color(0xFFE0E0DA);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: fieldBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? mediumGreen,
                  size: 22,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? darkGreen,
                    ),
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: hintGrey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
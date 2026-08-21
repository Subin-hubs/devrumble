import 'dart:ui';
import 'package:dev_rumble/screens/camera/camera.dart';
import 'package:dev_rumble/screens/crop/crop.dart';
import 'package:dev_rumble/screens/home/home.dart';
import 'package:dev_rumble/screens/market/market.dart';
import 'package:dev_rumble/screens/profile/profile.dart';
import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  final int currentIndex;
  final bool navigation;

  const Navbar(
      this.currentIndex,
      this.navigation, {
        super.key,
      });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  late int currentIndex;
  late bool navigation;

  late final PageController _pageController;

  final List<Widget> pages = const [
    Home(),
    Crop(),
    Camera(),
    Market(),
    Profile(),
  ];

  final List<_NavItem> navItems = const [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.eco_outlined,
      activeIcon: Icons.eco,
      label: 'Crops',
    ),
    _NavItem(
      icon: Icons.camera_alt_outlined,
      activeIcon: Icons.camera_alt,
      label: 'Scan',
    ),
    _NavItem(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      label: 'Market',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();

    currentIndex = widget.currentIndex;
    navigation = widget.navigation;

    _pageController = PageController(
      initialPage: currentIndex,
    );
  }
  void _onTabTapped(int index) {
    if (index == currentIndex) return;

    setState(() {
      currentIndex = index;
    });

    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: pages,
      ),

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  Widget _buildBottomNavigationBar() {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 82,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 12,
              right: 12,
              bottom: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 10,
                  ),
                  child: Container(
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 20,
              right: 20,
              bottom: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0),
                  _buildNavItem(1),

                  const SizedBox(width: 72),

                  _buildNavItem(3),
                  _buildNavItem(4),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: Center(
                child: _buildScanButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = navItems[index];
    final bool selected = currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabTapped(index),
      child: SizedBox(
        width: 58,
        height: 62,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE8F5E9)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                size: 23,
                color: selected
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    final bool selected = currentIndex == 2;

    return GestureDetector(
      onTap: () => _onTabTapped(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2E7D32),
          border: Border.all(
            color: Colors.white,
            width: 5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.30),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected
                  ? Icons.camera_alt
                  : Icons.camera_alt_outlined,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final VoidCallback onAddFood;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddFood,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Home
            _buildNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              isActive: currentIndex == 0,
              onTap: () => onTabSelected(0),
            ),

            // Dashboard
            _buildNavItem(
              icon: Icons.space_dashboard_outlined,
              activeIcon: Icons.dashboard,
              isActive: currentIndex == 1,
              onTap: () => onTabSelected(1),
            ),

            // Profile
            _buildNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              isActive: currentIndex == 2,
              onTap: () => onTabSelected(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(isActive ? activeIcon : icon),
      color: isActive ? Colors.green : Colors.grey,
      onPressed: onTap,
    );
  }
}

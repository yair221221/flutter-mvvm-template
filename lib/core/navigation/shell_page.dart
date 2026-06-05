import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/friends/friends_page.dart';
import '../../presentation/viewmodels/friends_viewmodel.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final requestCount = context.select<FriendsViewModel, int>(
        (vm) => vm.requestCount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardPage(),
          FriendsPage(),
        ],
      ),
      bottomNavigationBar: _NeonNavBar(
        currentIndex: _currentIndex,
        requestBadge: requestCount,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Neon bottom nav bar ────────────────────────────────────────────────────────

class _NeonNavBar extends StatelessWidget {
  final int currentIndex;
  final int requestBadge;
  final void Function(int) onTap;

  const _NeonNavBar({
    required this.currentIndex,
    required this.requestBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.background,
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.monitor_heart_outlined,
                activeIcon: Icons.monitor_heart_rounded,
                label: 'Wellness',
                badge: 0,
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.people_outline_rounded,
                activeIcon: Icons.people_rounded,
                label: 'Friends',
                badge: requestBadge,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badge;
  final void Function(int) onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.badge,
    required this.onTap,
  });

  bool get _active => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    final color = _active ? AppColors.cyan : AppColors.onSurfaceVariant;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        decoration: _active
            ? BoxDecoration(
                color: AppColors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.cyan.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.cyan.withOpacity(0.2), blurRadius: 14),
                ],
              )
            : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(
                _active ? activeIcon : icon,
                color: color,
                size: 22,
                shadows: _active
                    ? [Shadow(color: AppColors.cyan.withOpacity(0.6), blurRadius: 8)]
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.sora(
                  fontSize: 10,
                  fontWeight:
                      _active ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ]),
            // Badge
            if (badge > 0)
              Positioned(
                top: -4,
                right: -10,
                child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.cyan,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.cyan.withOpacity(0.5),
                          blurRadius: 6),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: GoogleFonts.sora(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: AppColors.background),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

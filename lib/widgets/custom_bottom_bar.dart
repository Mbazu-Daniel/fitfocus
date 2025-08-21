import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom BottomNavigationBar implementing Mindful Minimalism design
/// with contextual navigation optimized for health and productivity apps.
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final BottomBarVariant variant;
  final bool showLabels;
  final double elevation;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = BottomBarVariant.standard,
    this.showLabels = true,
    this.elevation = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: _buildBottomBar(context, theme),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ThemeData theme) {
    switch (variant) {
      case BottomBarVariant.floating:
        return _buildFloatingBottomBar(context, theme);
      case BottomBarVariant.standard:
      default:
        return _buildStandardBottomBar(context, theme);
    }
  }

  Widget _buildStandardBottomBar(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        HapticFeedback.lightImpact(); // Haptic micro-feedback
        onTap(index);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
      showSelectedLabels: showLabels,
      showUnselectedLabels: showLabels,
      elevation: 0, // Handled by container decoration
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      items: _getNavigationItems(context, theme),
    );
  }

  Widget _buildFloatingBottomBar(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _getNavigationItems(context, theme)
            .asMap()
            .entries
            .map((entry) => _buildFloatingNavItem(
                  context,
                  theme,
                  entry.value,
                  entry.key,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFloatingNavItem(
    BuildContext context,
    ThemeData theme,
    BottomNavigationBarItem item,
    int index,
  ) {
    final colorScheme = theme.colorScheme;
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconTheme(
                data: IconThemeData(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 24,
                ),
                child: item.icon,
              ),
            ),
            if (showLabels) ...[
              const SizedBox(height: 4),
              Text(
                item.label ?? '',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _getNavigationItems(
      BuildContext context, ThemeData theme) {
    return [
      BottomNavigationBarItem(
        icon: _buildNavIcon(Icons.timer_outlined, Icons.timer),
        label: 'Focus',
        tooltip: 'Pomodoro Timer',
      ),
      BottomNavigationBarItem(
        icon:
            _buildNavIcon(Icons.fitness_center_outlined, Icons.fitness_center),
        label: 'Exercise',
        tooltip: 'Exercise Library',
      ),
      BottomNavigationBarItem(
        icon: _buildNavIcon(Icons.trending_up_outlined, Icons.trending_up),
        label: 'Progress',
        tooltip: 'Progress Tracking',
      ),
    ];
  }

  Widget _buildNavIcon(IconData outlinedIcon, IconData filledIcon) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        currentIndex == _getIconIndex(outlinedIcon) ? filledIcon : outlinedIcon,
        key: ValueKey(currentIndex == _getIconIndex(outlinedIcon)),
      ),
    );
  }

  int _getIconIndex(IconData icon) {
    if (icon == Icons.timer_outlined) return 0;
    if (icon == Icons.fitness_center_outlined) return 1;
    if (icon == Icons.trending_up_outlined) return 2;
    return -1;
  }

  /// Navigation handler that manages route transitions
  static void handleNavigation(BuildContext context, int index) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    String targetRoute;

    switch (index) {
      case 0:
        targetRoute = '/pomodoro-timer';
        break;
      case 1:
        targetRoute = '/exercise-library';
        break;
      case 2:
        targetRoute = '/progress-tracking';
        break;
      default:
        return;
    }

    // Avoid navigating to the same route
    if (currentRoute == targetRoute) return;

    // Use pushReplacementNamed to maintain clean navigation stack
    Navigator.pushReplacementNamed(context, targetRoute);
  }
}

/// Enum defining different BottomBar variants
enum BottomBarVariant {
  standard,
  floating,
}

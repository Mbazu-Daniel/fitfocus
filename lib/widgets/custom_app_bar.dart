import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget implementing Mindful Minimalism design principles
/// with contextual navigation and clean visual hierarchy for health apps.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final AppBarVariant variant;
  final bool showNotificationBadge;
  final int notificationCount;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 2.0,
    this.variant = AppBarVariant.standard,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: _getTitleStyle(theme, variant),
      ),
      centerTitle: centerTitle,
      backgroundColor:
          backgroundColor ?? _getBackgroundColor(colorScheme, variant),
      foregroundColor:
          foregroundColor ?? _getForegroundColor(colorScheme, variant),
      elevation: elevation,
      shadowColor: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
      surfaceTintColor: Colors.transparent,
      leading: _buildLeading(context, theme),
      actions: _buildActions(context, theme),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, ThemeData theme) {
    if (leading != null) return leading;

    if (showBackButton && Navigator.of(context).canPop()) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
        ),
        onPressed: () {
          HapticFeedback.lightImpact(); // Haptic micro-feedback
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).pop();
          }
        },
        tooltip: 'Back',
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context, ThemeData theme) {
    if (actions != null) return actions;

    // Default actions based on current route and app context
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final List<Widget> defaultActions = [];

    switch (currentRoute) {
      case '/pomodoro-timer':
        defaultActions.addAll([
          IconButton(
            icon: Icon(Icons.settings_outlined, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Navigate to settings or show settings bottom sheet
            },
            tooltip: 'Timer Settings',
          ),
          _buildNotificationAction(context, theme),
        ]);
        break;
      case '/exercise-library':
        defaultActions.addAll([
          IconButton(
            icon: Icon(Icons.search_rounded, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Implement search functionality
            },
            tooltip: 'Search Exercises',
          ),
          IconButton(
            icon: Icon(Icons.filter_list_rounded, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Show filter bottom sheet
            },
            tooltip: 'Filter',
          ),
        ]);
        break;
      case '/progress-tracking':
        defaultActions.addAll([
          IconButton(
            icon: Icon(Icons.calendar_today_outlined, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Show date picker or calendar view
            },
            tooltip: 'Select Date Range',
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Share progress report
            },
            tooltip: 'Share Progress',
          ),
        ]);
        break;
      default:
        if (showNotificationBadge) {
          defaultActions.add(_buildNotificationAction(context, theme));
        }
    }

    return defaultActions.isNotEmpty ? defaultActions : null;
  }

  Widget _buildNotificationAction(BuildContext context, ThemeData theme) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, size: 22),
          onPressed: () {
            HapticFeedback.lightImpact();
            // Navigate to notifications or show notification panel
          },
          tooltip: 'Notifications',
        ),
        if (showNotificationBadge && notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                notificationCount > 99 ? '99+' : notificationCount.toString(),
                style: GoogleFonts.inter(
                  color: theme.colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  TextStyle _getTitleStyle(ThemeData theme, AppBarVariant variant) {
    switch (variant) {
      case AppBarVariant.large:
        return GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? theme.colorScheme.onSurface,
          letterSpacing: 0,
        );
      case AppBarVariant.medium:
        return GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? theme.colorScheme.onSurface,
          letterSpacing: 0,
        );
      case AppBarVariant.standard:
      default:
        return GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? theme.colorScheme.onSurface,
          letterSpacing: 0.15,
        );
    }
  }

  Color _getBackgroundColor(ColorScheme colorScheme, AppBarVariant variant) {
    switch (variant) {
      case AppBarVariant.transparent:
        return Colors.transparent;
      case AppBarVariant.primary:
        return colorScheme.primary;
      case AppBarVariant.surface:
      case AppBarVariant.standard:
      case AppBarVariant.medium:
      case AppBarVariant.large:
      default:
        return colorScheme.surface;
    }
  }

  Color _getForegroundColor(ColorScheme colorScheme, AppBarVariant variant) {
    switch (variant) {
      case AppBarVariant.primary:
        return colorScheme.onPrimary;
      case AppBarVariant.transparent:
      case AppBarVariant.surface:
      case AppBarVariant.standard:
      case AppBarVariant.medium:
      case AppBarVariant.large:
      default:
        return colorScheme.onSurface;
    }
  }

  @override
  Size get preferredSize {
    switch (variant) {
      case AppBarVariant.large:
        return const Size.fromHeight(72.0);
      case AppBarVariant.medium:
        return const Size.fromHeight(64.0);
      case AppBarVariant.standard:
      default:
        return const Size.fromHeight(56.0);
    }
  }
}

/// Enum defining different AppBar variants for various use cases
enum AppBarVariant {
  standard,
  medium,
  large,
  primary,
  surface,
  transparent,
}

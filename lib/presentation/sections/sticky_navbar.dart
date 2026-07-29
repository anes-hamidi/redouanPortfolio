import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/section_type.dart';
import '../../providers/theme_provider.dart';
import '../components/hover_builder.dart';

/// Sticky Top Navigation Bar Component with Riverpod Theme Mode Support
class StickyNavbar extends ConsumerWidget {
  final SectionType activeSection;
  final bool isMobile;
  final ValueChanged<SectionType> onSectionSelect;

  const StickyNavbar({
    super.key,
    required this.activeSection,
    required this.isMobile,
    required this.onSectionSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1424).withValues(alpha: 0.95) : AppColors.navy.withValues(alpha: 0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: const Border(
          bottom: BorderSide(
            color: AppColors.gold,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo / Brand
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSectionSelect(SectionType.home),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.brandName,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                      color: AppColors.gold,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    AppStrings.brandSubtitle,
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: isMobile ? 9 : 11,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Menu Items & Theme Toggle
          Row(
            children: [
              if (!isMobile) ...[
                _buildNavItem(SectionType.home, AppStrings.navHome),
                _buildNavItem(SectionType.about, AppStrings.navAbout),
                _buildNavItem(SectionType.services, AppStrings.navServices),
                _buildNavItem(SectionType.media, AppStrings.navMedia),
                _buildNavItem(SectionType.whyChoose, AppStrings.navWhyChoose),
                _buildNavItem(SectionType.contact, AppStrings.navContact),
                const SizedBox(width: 16),
                _buildBookCTAButton(),
                const SizedBox(width: 16),
              ],

              // Theme Mode Switcher Icon
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    key: ValueKey(isDark),
                    color: AppColors.gold,
                    size: 22,
                  ),
                ),
                onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                tooltip: isDark ? 'Passer en Mode Clair' : 'Passer en Mode Nuit Andalouse',
              ),

              if (isMobile)
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.gold, size: 28),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(SectionType section, String label) {
    final isActive = activeSection == section;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, isHovered) {
        return GestureDetector(
          onTap: () => onSectionSelect(section),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'sans-serif',
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                    color: isActive
                        ? AppColors.gold
                        : (isHovered ? AppColors.gold.withValues(alpha: 0.8) : Colors.white),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 2,
                  width: isActive ? 24 : (isHovered ? 16 : 0),
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookCTAButton() {
    return HoverBuilder(
      builder: (context, isHovered) {
        return OutlinedButton(
          onPressed: () => onSectionSelect(SectionType.contact),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: AppColors.gold,
              width: isHovered ? 2 : 1.5,
            ),
            backgroundColor: isHovered ? AppColors.gold : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            AppStrings.navBookCTA,
            style: TextStyle(
              fontFamily: 'sans-serif',
              fontWeight: FontWeight.bold,
              color: isHovered ? AppColors.navy : AppColors.gold,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        );
      },
    );
  }
}

/// Mobile Side Drawer Menu
class MobileDrawer extends ConsumerWidget {
  final SectionType activeSection;
  final ValueChanged<SectionType> onSectionSelect;

  const MobileDrawer({
    super.key,
    required this.activeSection,
    required this.onSectionSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0D1424) : AppColors.navy,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.gold, width: 1),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    AppStrings.brandName,
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.gold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.brandDrawerSubtitle,
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, SectionType.home, Icons.home, AppStrings.navHome),
                _buildDrawerItem(context, SectionType.about, Icons.person, AppStrings.navAbout),
                _buildDrawerItem(context, SectionType.services, Icons.star, AppStrings.navServices),
                _buildDrawerItem(context, SectionType.media, Icons.audiotrack, AppStrings.navMedia),
                _buildDrawerItem(context, SectionType.whyChoose, Icons.check_circle, AppStrings.navWhyChoose),
                _buildDrawerItem(context, SectionType.contact, Icons.event, AppStrings.navContact),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: AppColors.gold,
              ),
              title: Text(
                isDark ? 'Mode Clair' : 'Mode Nuit Andalouse',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              '© ${DateTime.now().year} ${AppStrings.brandName}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, SectionType section, IconData icon, String label) {
    final isActive = activeSection == section;
    return ListTile(
      leading: Icon(icon, color: isActive ? AppColors.gold : Colors.white70),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.gold : Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
        ),
      ),
      selected: isActive,
      onTap: () {
        Navigator.pop(context);
        onSectionSelect(section);
      },
    );
  }
}

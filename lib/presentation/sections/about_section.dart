import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

import '../../core/constants/app_data.dart';
import '../../core/constants/app_strings.dart';
import '../components/section_header.dart';

/// About Section Component
class AboutSection extends StatelessWidget {
  final GlobalKey sectionKey;
  final bool isMobile;

  const AboutSection({
    super.key,
    required this.sectionKey,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sectionKey,
      color: AppColors.cream,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Section Header
              const SectionHeader(
                tagline: AppStrings.aboutTagline,
                title: AppStrings.artistName,
              ),
              const SizedBox(height: 60),

              // Responsive Bio Layout
              isMobile
                  ? Column(
                      children: [
                        _buildAboutPortrait(),
                        const SizedBox(height: 48),
                        _buildAboutText(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: _buildAboutPortrait()),
                        const SizedBox(width: 64),
                        Expanded(flex: 6, child: _buildAboutText()),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutPortrait() {
    return SizedBox(
      height: 420,
      width: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Gold Frame Offset
          Positioned(
            top: 20,
            left: 20,
            right: -20,
            bottom: -20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.gold,
                  width: 2,
                ),
              ),
            ),
          ),
          // Profile Image
          Positioned.fill(
            child: Image.asset(
              AppAssets.redouanePortrait,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.navy,
                  child: const Center(
                    child: Icon(Icons.music_note, color: AppColors.gold, size: 64),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.aboutSubhead,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          AppStrings.aboutBio1,
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 16,
            height: 1.7,
            color: AppColors.bodyText,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          AppStrings.aboutBio2,
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 16,
            height: 1.7,
            color: AppColors.bodyText,
          ),
        ),
        const SizedBox(height: 36),

        // Mini Stats Cards
        Row(
          children: AppData.stats
              .map((stat) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: _buildStatItem(stat.count, stat.label),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: const TextStyle(
              fontFamily: 'serif',
              color: AppColors.gold,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'sans-serif',
              color: AppColors.bodyText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

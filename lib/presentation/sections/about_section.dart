import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

import '../../core/constants/app_data.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/responsive_breakpoints.dart';
import '../components/fade_in_slide.dart';
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
    final isPhone = ResponsiveBreakpoints.isPhone(context);
    final containerMaxWidth = ResponsiveBreakpoints.maxContainerWidth(context);
    final horizPadding = ResponsiveBreakpoints.horizontalPadding(context);
    final vertPadding = ResponsiveBreakpoints.verticalPadding(context);

    return Container(
      key: sectionKey,
      color: AppColors.cream,
      padding: EdgeInsets.symmetric(horizontal: horizPadding, vertical: vertPadding),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: containerMaxWidth),
          child: Column(
            children: [
              // Section Header
              const FadeInSlide(
                child: SectionHeader(
                  tagline: AppStrings.aboutTagline,
                  title: AppStrings.artistName,
                ),
              ),
              SizedBox(height: isPhone ? 36 : 60),

              // Responsive Bio Layout
              isPhone
                  ? Column(
                      children: [
                        FadeInSlide(
                          delay: const Duration(milliseconds: 100),
                          child: _buildAboutPortrait(context),
                        ),
                        const SizedBox(height: 40),
                        FadeInSlide(
                          delay: const Duration(milliseconds: 200),
                          child: _buildAboutText(context),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: FadeInSlide(
                            delay: const Duration(milliseconds: 100),
                            child: _buildAboutPortrait(context),
                          ),
                        ),
                        SizedBox(width: ResponsiveBreakpoints.value<double>(context, phone: 24, tablet: 40, desktop: 64)),
                        Expanded(
                          flex: 6,
                          child: FadeInSlide(
                            delay: const Duration(milliseconds: 200),
                            child: _buildAboutText(context),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutPortrait(BuildContext context) {
    final isPhone = ResponsiveBreakpoints.isPhone(context);
    final height = isPhone ? 340.0 : 420.0;
    final width = isPhone ? 260.0 : 320.0;

    return Center(
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background Gold Frame Offset
            Positioned(
              top: 16,
              left: 16,
              right: -16,
              bottom: -16,
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
      ),
    );
  }

  Widget _buildAboutText(BuildContext context) {
    final isPhone = ResponsiveBreakpoints.isPhone(context);
    final isTv = ResponsiveBreakpoints.isTv(context);

    final subheadSize = isTv ? 26.0 : (isPhone ? 19.0 : 22.0);
    final bioSize = isTv ? 18.0 : (isPhone ? 14.5 : 16.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.aboutSubhead,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: subheadSize,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppStrings.aboutBio1,
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: bioSize,
            height: 1.7,
            color: AppColors.bodyText,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.aboutBio2,
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: bioSize,
            height: 1.7,
            color: AppColors.bodyText,
          ),
        ),
        const SizedBox(height: 36),

        // Mini Stats Cards (Wrap on phone screen to prevent overflow)
        LayoutBuilder(
          builder: (context, constraints) {
            final isTight = constraints.maxWidth < 450;
            if (isTight) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppData.stats
                    .map((stat) => SizedBox(
                          width: (constraints.maxWidth - 12) / 2,
                          child: _buildStatItem(stat.count, stat.label, isTv),
                        ))
                    .toList(),
              );
            }
            return Row(
              children: AppData.stats
                  .map((stat) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: _buildStatItem(stat.count, stat.label, isTv),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label, bool isTv) {
    return Container(
      padding: EdgeInsets.all(isTv ? 20 : 16),
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
            style: TextStyle(
              fontFamily: 'serif',
              color: AppColors.gold,
              fontSize: isTv ? 28 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'sans-serif',
              color: AppColors.bodyText,
              fontSize: isTv ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}


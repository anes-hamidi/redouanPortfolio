import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/responsive_breakpoints.dart';
import '../components/fade_in_slide.dart';

/// Hero Section Component
class HeroSection extends StatelessWidget {
  final GlobalKey sectionKey;
  final Size size;
  final bool isMobile;
  final VoidCallback onBookTap;
  final VoidCallback onMediaTap;

  const HeroSection({
    super.key,
    required this.sectionKey,
    required this.size,
    required this.isMobile,
    required this.onBookTap,
    required this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    final headlineFontSize = ResponsiveBreakpoints.value<double>(
      context,
      phone: 28,
      tablet: 40,
      desktop: 54,
      tv: 68,
    );
    final subtitleFontSize = ResponsiveBreakpoints.value<double>(
      context,
      phone: 14,
      tablet: 17,
      desktop: 19,
      tv: 23,
    );
    final taglineFontSize = ResponsiveBreakpoints.value<double>(
      context,
      phone: 10,
      tablet: 11,
      desktop: 12,
      tv: 14,
    );
    final containerMaxWidth = ResponsiveBreakpoints.maxContainerWidth(context);

    // Flexible minimum height to avoid mobile overflow on landscape/short screens
    final minHeroHeight = size.height > 560 ? size.height : 560.0;

    return Container(
      key: sectionKey,
      constraints: BoxConstraints(minHeight: minHeroHeight),
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppAssets.heroPerformance,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.heroBackground,
                        AppColors.navy,
                        Color(0xFF1E1E2F),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Dark Overlay Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.navy.withValues(alpha: 0.6),
                    AppColors.navy.withValues(alpha: 0.85),
                    AppColors.cream,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Hero Content
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: containerMaxWidth),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveBreakpoints.horizontalPadding(context),
                vertical: 40.0,
              ),
              margin: const EdgeInsets.only(top: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Golden Tagline Pill
                  FadeInSlide(
                    delay: Duration.zero,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gold, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.gold.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        AppStrings.heroTagline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: taglineFontSize,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main Headline
                  FadeInSlide(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      AppStrings.heroHeadline,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'serif',
                        color: Colors.white,
                        fontSize: headlineFontSize,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Subtitle
                  FadeInSlide(
                    delay: const Duration(milliseconds: 180),
                    child: Text(
                      AppStrings.heroSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: subtitleFontSize,
                        height: 1.6,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Dual CTA Buttons
                  FadeInSlide(
                    delay: const Duration(milliseconds: 260),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                    children: [
                      // Primary CTA
                      ElevatedButton(
                        onPressed: onBookTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 5,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.heroCtaPrimary,
                              style: TextStyle(
                                fontFamily: 'sans-serif',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),

                      // Secondary CTA
                      OutlinedButton(
                        onPressed: onMediaTap,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppStrings.heroCtaSecondary,
                              style: TextStyle(
                                fontFamily: 'sans-serif',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.play_circle_outline, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

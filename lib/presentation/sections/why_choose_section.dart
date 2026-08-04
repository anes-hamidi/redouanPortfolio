import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_data.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/responsive_breakpoints.dart';
import '../components/fade_in_slide.dart';
import '../components/section_header.dart';

/// Why Choose Section Component
class WhyChooseSection extends StatelessWidget {
  final GlobalKey sectionKey;
  final bool isMobile;

  const WhyChooseSection({
    super.key,
    required this.sectionKey,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final horizPadding = ResponsiveBreakpoints.horizontalPadding(context);
    final vertPadding = ResponsiveBreakpoints.verticalPadding(context);
    final containerMaxWidth = ResponsiveBreakpoints.maxContainerWidth(context);
    final isPhone = ResponsiveBreakpoints.isPhone(context);

    return Container(
      key: sectionKey,
      color: AppColors.navy,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizPadding, vertical: vertPadding),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: containerMaxWidth),
          child: Column(
            children: [
              // Section Header
              const FadeInSlide(
                child: SectionHeader(
                  tagline: AppStrings.whyChooseTagline,
                  title: AppStrings.whyChooseTitle,
                  titleColor: Colors.white,
                ),
              ),
              const SizedBox(height: 64),

              // 3 Pillars Row / Column Layout
              isPhone
                  ? Column(
                      children: AppData.pillars.asMap().entries
                          .map((entry) {
                            final index = entry.key;
                            final pillar = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 40.0),
                              child: FadeInSlide(
                                delay: Duration(milliseconds: index * 80),
                                child: _buildPillarItem(pillar.icon, pillar.title, pillar.description),
                              ),
                            );
                          })
                          .toList(),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AppData.pillars.asMap().entries
                          .map(
                            (entry) {
                              final index = entry.key;
                              final pillar = entry.value;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: FadeInSlide(
                                    delay: Duration(milliseconds: index * 80),
                                    child: _buildPillarItem(pillar.icon, pillar.title, pillar.description),
                                  ),
                                ),
                              );
                            },
                          )
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillarItem(IconData icon, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold, width: 1.5),
          ),
          child: Icon(icon, color: AppColors.gold, size: 28),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'serif',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'sans-serif',
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

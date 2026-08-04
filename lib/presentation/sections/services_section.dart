import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_data.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/responsive_breakpoints.dart';
import '../components/fade_in_slide.dart';
import '../components/hover_builder.dart';
import '../components/section_header.dart';

/// Services Section Component
class ServicesSection extends StatelessWidget {
  final GlobalKey sectionKey;
  final bool isMobile;

  const ServicesSection({
    super.key,
    required this.sectionKey,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final horizPadding = ResponsiveBreakpoints.horizontalPadding(context);
    final vertPadding = ResponsiveBreakpoints.verticalPadding(context);
    final containerMaxWidth = ResponsiveBreakpoints.maxContainerWidth(context);

    return Container(
      key: sectionKey,
      color: AppColors.darkCharcoal,
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
                  tagline: AppStrings.servicesTagline,
                  title: AppStrings.servicesTitle,
                  titleColor: Colors.white,
                ),
              ),
              const SizedBox(height: 64),

              // Grid of Interactive Service Cards (1 col phone, 2 col tablet/desktop, 4 col TV)
              LayoutBuilder(
                builder: (context, constraints) {
                  int columns = 2;
                  if (constraints.maxWidth < 650) {
                    columns = 1;
                  } else if (constraints.maxWidth >= 1350) {
                    columns = 4;
                  } else {
                    columns = 2;
                  }
                  final double spacing = 24.0;
                  final double cardWidth = (constraints.maxWidth - (columns - 1) * spacing) / columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: AppData.services.asMap().entries.map((entry) {
                      final index = entry.key;
                      final service = entry.value;
                      return SizedBox(
                        width: cardWidth,
                        child: FadeInSlide(
                          delay: Duration(milliseconds: index * 70),
                          child: _buildServiceCard(
                            service.icon,
                            service.title,
                            service.description,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(IconData icon, String title, String description) {
    return HoverBuilder(
      builder: (context, isHovered) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: AppColors.cardDarkSlate.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isHovered ? AppColors.gold : AppColors.cardBorderSlate,
              width: 1.5,
            ),
            boxShadow: [
              if (isHovered)
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHovered ? AppColors.gold : AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  icon,
                  color: isHovered ? AppColors.darkCharcoal : AppColors.gold,
                  size: 24,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
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
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

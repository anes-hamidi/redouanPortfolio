import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_data.dart';
import '../../core/constants/app_strings.dart';
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
    final double paddingVal = isMobile ? 24.0 : 64.0;
    return Container(
      key: sectionKey,
      color: AppColors.darkCharcoal,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: paddingVal, vertical: 100.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Section Header
              const SectionHeader(
                tagline: AppStrings.servicesTagline,
                title: AppStrings.servicesTitle,
                titleColor: Colors.white,
              ),
              const SizedBox(height: 64),

              // Grid of Interactive Service Cards
              isMobile
                  ? Column(
                      children: AppData.services
                          .map((service) => Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: _buildServiceCard(
                                  service.icon,
                                  service.title,
                                  service.description,
                                ),
                              ))
                          .toList(),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        double cardWidth = (constraints.maxWidth - 24) / 2;
                        return Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          children: AppData.services
                              .map(
                                (service) => SizedBox(
                                  width: cardWidth,
                                  child: _buildServiceCard(
                                    service.icon,
                                    service.title,
                                    service.description,
                                  ),
                                ),
                              )
                              .toList(),
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

import 'package:flutter/material.dart';
import 'package:portfolio/core/theme/responsive_breakpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../components/hover_builder.dart';

/// Footer Section Component
class FooterSection extends StatelessWidget {
  final GlobalKey sectionKey;
  final bool isMobile;
  final Function(int sectionIndex)? onNavigateSection;

  const FooterSection({
    super.key,
    required this.sectionKey,
    required this.isMobile,
    this.onNavigateSection,
  });

  @override
  Widget build(BuildContext context) {
  final usesDrawer = ResponsiveBreakpoints.usesMobileDrawer(context);

    return Container(
      key: sectionKey,
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Brand Name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        AppStrings.brandSubtitle,
                        style: TextStyle(
                          fontFamily: 'sans-serif',
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                          letterSpacing: 2,
                        ),
                      ),
                      if (usesDrawer)
                      Row(
                        children: [
                      _buildSocialIconButton(Icons.music_note, 'TikTok'),
                      const SizedBox(width: 12),
                      _buildSocialIconButton(Icons.camera_alt, 'Instagram'),
                      const SizedBox(width: 12),
                      _buildSocialIconButton(Icons.video_library, 'YouTube'),
                    
                        ],
                      ),
                    ],
                  ),
                 if (!usesDrawer)
                  // Social Icons
                  Row(
                    children: [
                      _buildSocialIconButton(Icons.music_note, 'TikTok'),
                      const SizedBox(width: 12),
                      _buildSocialIconButton(Icons.camera_alt, 'Instagram'),
                      const SizedBox(width: 12),
                      _buildSocialIconButton(Icons.video_library, 'YouTube'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 24),

              Text(
                AppStrings.footerCopyright,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIconButton(IconData icon, String tooltip) {
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, isHovered) {
        return IconButton(
          tooltip: tooltip,
          icon: Icon(
            icon,
            color: isHovered ? AppColors.navy : AppColors.gold,
            size: 20,
          ),
          style: IconButton.styleFrom(
            backgroundColor: isHovered ? AppColors.gold : AppColors.gold.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(12),
          ),
          onPressed: () {},
        );
      },
    );
  }
}

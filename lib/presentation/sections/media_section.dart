import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../components/audio_player_widget.dart';
import '../components/hover_builder.dart';
import '../components/section_header.dart';

/// Media & Audio Showcase Section
class MediaSection extends StatelessWidget {
  final GlobalKey sectionKey;
  final bool isMobile;

  const MediaSection({
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
                tagline: AppStrings.mediaTagline,
                title: AppStrings.mediaTitle,
              ),
              const SizedBox(height: 60),

              // Responsive Layout Split: Player & Photos
              isMobile
                  ? Column(
                      children: [
                        const AudioPlayerWidget(),
                        const SizedBox(height: 64),
                        _buildPhotoGallery(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 5,
                          child: AudioPlayerWidget(),
                        ),
                        const SizedBox(width: 48),
                        Expanded(
                          flex: 6,
                          child: _buildPhotoGallery(),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.galleryTitle,
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 2,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          AppStrings.gallerySubtitle,
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 15,
            color: AppColors.bodyText,
          ),
        ),
        const SizedBox(height: 32),

        // Photo Grid
        LayoutBuilder(
          builder: (context, constraints) {
            double sizeVal = (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildGalleryImage('Mariage Célébration', AppAssets.weddingPerformance, sizeVal),
                _buildGalleryImage('Tradition Tlemcen', AppAssets.tlemcenHeritage, sizeVal),
                _buildGalleryImage('Concert sur Scène', AppAssets.heroPerformance, sizeVal),
                _buildGalleryImage('Portrait Privé', AppAssets.redouanePortrait, sizeVal),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGalleryImage(String label, String imagePath, double size) {
    return HoverBuilder(
      builder: (context, isHovered) {
        return Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.darkCharcoal,
                      child: const Center(
                        child: Icon(Icons.image, color: AppColors.gold, size: 40),
                      ),
                    );
                  },
                ),
              ),
              // Hover Overlay
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: isHovered ? AppColors.navy.withValues(alpha: 0.85) : Colors.transparent,
                  child: isHovered
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.zoom_in, color: AppColors.gold, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                label,
                                style: const TextStyle(
                                  fontFamily: 'serif',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

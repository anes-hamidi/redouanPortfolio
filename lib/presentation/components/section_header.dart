import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable section title header component
class SectionHeader extends StatelessWidget {
  final String tagline;
  final String title;
  final Color taglineColor;
  final Color titleColor;

  const SectionHeader({
    super.key,
    required this.tagline,
    required this.title,
    this.taglineColor = AppColors.gold,
    this.titleColor = AppColors.navy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'sans-serif',
            color: taglineColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'serif',
            color: titleColor,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 2,
          width: 80,
          color: AppColors.gold,
        ),
      ],
    );
  }
}

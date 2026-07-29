import 'package:flutter/material.dart';

/// Model class for quality commitment pillars
class PillarModel {
  final IconData icon;
  final String title;
  final String description;

  const PillarModel({
    required this.icon,
    required this.title,
    required this.description,
  });
}

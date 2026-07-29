import 'package:flutter/material.dart';

/// Model class for service cards
class ServiceModel {
  final IconData icon;
  final String title;
  final String description;

  const ServiceModel({
    required this.icon,
    required this.title,
    required this.description,
  });
}

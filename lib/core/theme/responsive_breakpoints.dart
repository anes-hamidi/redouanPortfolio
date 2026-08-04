import 'package:flutter/material.dart';

/// Multi-device category types
enum DeviceType {
  phone,
  tablet,
  desktop,
  tv,
}

/// Centralized responsive layout engine & breakpoint metrics
class ResponsiveBreakpoints {
  // Screen width breakpoints (in logical pixels)
  static const double phoneMax = 650;
  static const double tabletMax = 1100;
  static const double desktopMax = 1800;

  /// Returns the active DeviceType for the given context
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < phoneMax) {
      return DeviceType.phone;
    } else if (width < tabletMax) {
      return DeviceType.tablet;
    } else if (width < desktopMax) {
      return DeviceType.desktop;
    } else {
      return DeviceType.tv;
    }
  }

  static bool isPhone(BuildContext context) => getDeviceType(context) == DeviceType.phone;
  static bool isTablet(BuildContext context) => getDeviceType(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) => getDeviceType(context) == DeviceType.desktop;
  static bool isTv(BuildContext context) => getDeviceType(context) == DeviceType.tv;

  /// Convenience check for drawer-based UI navigation (Phones & Portrait Tablets)
  static bool usesMobileDrawer(BuildContext context) {
    final device = getDeviceType(context);
    return device == DeviceType.phone || device == DeviceType.tablet;
  }

  /// Resolves device-specific values with sensible fallbacks
  static T value<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
    required T desktop,
    T? tv,
  }) {
    final device = getDeviceType(context);
    switch (device) {
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.tv:
        return tv ?? desktop;
    }
  }

  /// Max container width for optimal content presentation across resolutions
  static double maxContainerWidth(BuildContext context) {
    final device = getDeviceType(context);
    switch (device) {
      case DeviceType.phone:
        return double.infinity;
      case DeviceType.tablet:
        return 920;
      case DeviceType.desktop:
        return 1150;
      case DeviceType.tv:
        return 1450;
    }
  }

  /// Responsive horizontal section padding
  static double horizontalPadding(BuildContext context) {
    final device = getDeviceType(context);
    switch (device) {
      case DeviceType.phone:
        return 16.0;
      case DeviceType.tablet:
        return 32.0;
      case DeviceType.desktop:
        return 64.0;
      case DeviceType.tv:
        return 96.0;
    }
  }

  /// Responsive vertical section padding
  static double verticalPadding(BuildContext context) {
    final device = getDeviceType(context);
    switch (device) {
      case DeviceType.phone:
        return 60.0;
      case DeviceType.tablet:
        return 80.0;
      case DeviceType.desktop:
        return 100.0;
      case DeviceType.tv:
        return 120.0;
    }
  }
}

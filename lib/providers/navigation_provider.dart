import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/section_type.dart';

/// Navigation & Scroll State Model
class NavigationState {
  final SectionType activeSection;
  final bool isScrolled;
  final bool showFloatingMiniPlayer;

  const NavigationState({
    this.activeSection = SectionType.home,
    this.isScrolled = false,
    this.showFloatingMiniPlayer = false,
  });

  NavigationState copyWith({
    SectionType? activeSection,
    bool? isScrolled,
    bool? showFloatingMiniPlayer,
  }) {
    return NavigationState(
      activeSection: activeSection ?? this.activeSection,
      isScrolled: isScrolled ?? this.isScrolled,
      showFloatingMiniPlayer:
          showFloatingMiniPlayer ?? this.showFloatingMiniPlayer,
    );
  }
}

/// Riverpod StateNotifier for managing app navigation and scroll position
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void setActiveSection(SectionType section) {
    if (state.activeSection != section) {
      state = state.copyWith(activeSection: section);
    }
  }

  void updateScrollInfo({required double scrollOffset}) {
    final scrolled = scrollOffset > 80;
    final showMini = scrollOffset > 600;
    if (state.isScrolled != scrolled || state.showFloatingMiniPlayer != showMini) {
      state = state.copyWith(
        isScrolled: scrolled,
        showFloatingMiniPlayer: showMini,
      );
    }
  }
}

/// Global Riverpod Provider for Navigation State
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});

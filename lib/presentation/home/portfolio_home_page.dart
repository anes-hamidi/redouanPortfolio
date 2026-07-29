import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../models/section_type.dart';

import '../../providers/navigation_provider.dart';
import '../../providers/theme_provider.dart';
import '../components/floating_mini_player.dart';
import '../components/floating_whatsapp_button.dart';

import '../sections/sticky_navbar.dart';
import '../sections/hero_section.dart';
import '../sections/about_section.dart';
import '../sections/services_section.dart';
import '../sections/media_section.dart';
import '../sections/why_choose_section.dart';
import '../sections/booking_section.dart';
import '../sections/footer_section.dart';

/// Main Single-Page Portfolio HomePage with Riverpod State & WhatsApp Integration
class PortfolioHomePage extends ConsumerStatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  ConsumerState<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends ConsumerState<PortfolioHomePage> {
  final ScrollController _scrollController = ScrollController();
  final Map<SectionType, GlobalKey> _sectionKeys = {
    for (var type in SectionType.values) type: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final navNotifier = ref.read(navigationProvider.notifier);
    final navState = ref.read(navigationProvider);

    navNotifier.updateScrollInfo(scrollOffset: _scrollController.offset);

    SectionType detectedSection = SectionType.home;
    double minDiff = double.infinity;

    _sectionKeys.forEach((key, value) {
      final context = value.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          double diff = (position.dy).abs();
          if (diff < minDiff) {
            minDiff = diff;
            detectedSection = key;
          }
        }
      }
    });

    if (detectedSection != navState.activeSection) {
      navNotifier.setActiveSection(detectedSection);
    }
  }

  void _scrollToSection(SectionType section) {
    final key = _sectionKeys[section];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 950;

    final navState = ref.watch(navigationProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : AppColors.cream,
      floatingActionButton: const FloatingWhatsappButton(),
      drawer: isMobile
          ? MobileDrawer(
              activeSection: navState.activeSection,
              onSectionSelect: _scrollToSection,
            )
          : null,
      body: Stack(
        children: [
          // Single Page Scrollable View
          SelectionArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  HeroSection(
                    sectionKey: _sectionKeys[SectionType.home]!,
                    size: size,
                    isMobile: isMobile,
                    onBookTap: () => _scrollToSection(SectionType.contact),
                    onMediaTap: () => _scrollToSection(SectionType.media),
                  ),
                  AboutSection(
                    sectionKey: _sectionKeys[SectionType.about]!,
                    isMobile: isMobile,
                  ),
                  ServicesSection(
                    sectionKey: _sectionKeys[SectionType.services]!,
                    isMobile: isMobile,
                  ),
                  MediaSection(
                    sectionKey: _sectionKeys[SectionType.media]!,
                    isMobile: isMobile,
                  ),
                  WhyChooseSection(
                    sectionKey: _sectionKeys[SectionType.whyChoose]!,
                    isMobile: isMobile,
                  ),
                  BookingSection(
                    sectionKey: _sectionKeys[SectionType.contact]!,
                    isMobile: isMobile,
                  ),
                  FooterSection(
                    sectionKey: GlobalKey(),
                    isMobile: isMobile,
                  ),
                ],
              ),
            ),
          ),

          // Sticky Top Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: StickyNavbar(
              activeSection: navState.activeSection,
              isMobile: isMobile,
              onSectionSelect: _scrollToSection,
            ),
          ),

          // Persistent Floating Mini-Player when scrolled
          if (navState.showFloatingMiniPlayer)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingMiniPlayer(
                  onTapExpand: () => _scrollToSection(SectionType.media),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

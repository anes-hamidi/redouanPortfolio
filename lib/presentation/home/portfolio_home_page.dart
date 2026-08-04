import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../models/section_type.dart';

import '../../providers/navigation_provider.dart';
import '../../providers/theme_provider.dart';
import '../components/floating_whatsapp_button.dart';

import '../sections/sticky_navbar.dart';
import '../sections/hero_section.dart';
import '../sections/about_section.dart';
import '../sections/services_section.dart';
import '../sections/media_section.dart';
import '../sections/why_choose_section.dart';
import '../sections/booking_section.dart';
import '../sections/footer_section.dart';

import '../../core/theme/responsive_breakpoints.dart';

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
  int _lastScrollCheck = 0;

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

    final now = DateTime.now().millisecondsSinceEpoch;
    final navNotifier = ref.read(navigationProvider.notifier);
    navNotifier.updateScrollInfo(scrollOffset: _scrollController.offset);

    // Throttle heavy RenderObject localToGlobal calculations to at most once per 60ms for 60/120fps smooth scrolling
    if (now - _lastScrollCheck < 60) return;
    _lastScrollCheck = now;

    final navState = ref.read(navigationProvider);
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
        duration: const Duration(milliseconds: 450),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final usesDrawer = ResponsiveBreakpoints.usesMobileDrawer(context);

    final navState = ref.watch(navigationProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : AppColors.cream,
      floatingActionButton: const FloatingWhatsappButton(),
      drawer: usesDrawer
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
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                children: [
                  HeroSection(
                    sectionKey: _sectionKeys[SectionType.home]!,
                    size: size,
                    isMobile: usesDrawer,
                    onBookTap: () => _scrollToSection(SectionType.contact),
                    onMediaTap: () => _scrollToSection(SectionType.media),
                  ),
                  BookingSection(
                    sectionKey: _sectionKeys[SectionType.contact]!,
                    isMobile: usesDrawer,
                  ),
                  ServicesSection(
                    sectionKey: _sectionKeys[SectionType.services]!,
                    isMobile: usesDrawer,
                  ),
                  AboutSection(
                    sectionKey: _sectionKeys[SectionType.about]!,
                    isMobile: usesDrawer,
                  ),
                  MediaSection(
                    sectionKey: _sectionKeys[SectionType.media]!,
                    isMobile: usesDrawer,
                  ),
                  WhyChooseSection(
                    sectionKey: _sectionKeys[SectionType.whyChoose]!,
                    isMobile: usesDrawer,
                  ),
                  FooterSection(
                    sectionKey: GlobalKey(),
                    isMobile: usesDrawer,
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
              isMobile: usesDrawer,
              onSectionSelect: _scrollToSection,
            ),
          ),

          // Persistent Floating Mini-Player when scrolled
          
        ],
      ),
    );
  }
}

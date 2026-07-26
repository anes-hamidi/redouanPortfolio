import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const RedouanePortfolioApp());
}

class RedouanePortfolioApp extends StatelessWidget {
  const RedouanePortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cheb Redouane Tlemcani | Portfolio Officiel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0A1128),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          primary: const Color(0xFF0A1128),
          secondary: const Color(0xFFD4AF37),
          background: const Color(0xFFFAF9F6),
        ),
        fontFamily: 'serif', // Elegant traditional default
        useMaterial3: true,
      ),
      home: const PortfolioHomePage(),
    );
  }
}

enum SectionType { home, about, services, media, whyChoose, contact }

class PortfolioHomePage extends StatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  final ScrollController _scrollController = ScrollController();
  final Map<SectionType, GlobalKey> _sectionKeys = {
    for (var type in SectionType.values) type: GlobalKey(),
  };

  SectionType _activeSection = SectionType.home;

  // Audio Player State
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  int _activeTrackIndex = 0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _completeSubscription;

  final List<Map<String, String>> _tracks = [
    {
      'title': 'Medley Tlemcani (Live)',
      'genre': 'Hawzi Traditionnel',
      'duration': '03:45',
      'seconds': '225',
      'assetPath': 'music/ssstik.io_1785097403401.mp3',
    },
    {
      'title': 'Wedding Celebration Live Set',
      'genre': 'Chaabi & Ambiance Mariage',
      'duration': '05:12',
      'seconds': '312',
      'assetPath': 'music/ssstik.io_1785097480783.mp3',
    },
    {
      'title': 'Ghorba & Nostalgie',
      'genre': 'Hawzi Moderne',
      'duration': '04:20',
      'seconds': '260',
      'assetPath': 'music/ssstik.io_1785097539169 (1).mp3',
    },
    {
      'title': 'Héritage Andalou (Acoustique)',
      'genre': 'Classique Tlemcen',
      'duration': '06:05',
      'seconds': '365',
      'assetPath': 'music/ssstik.io_1785097673668.mp3',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    _audioPlayer = AudioPlayer();
    
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        _duration = duration;
      });
    });
    
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        _position = position;
      });
    });
    
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _completeSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      _nextTrack();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _completeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    // Determine which section is currently most visible on screen
    SectionType detectedSection = SectionType.home;
    double minDiff = double.infinity;

    _sectionKeys.forEach((key, value) {
      final context = value.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          // Calculate distance from top of screen to the section start
          double diff = (position.dy).abs();
          if (diff < minDiff) {
            minDiff = diff;
            detectedSection = key;
          }
        }
      }
    });

    if (detectedSection != _activeSection) {
      setState(() {
        _activeSection = detectedSection;
      });
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

  // Audio Player Logic
  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      final activeTrack = _tracks[_activeTrackIndex];
      try {
        await _audioPlayer.play(AssetSource(activeTrack['assetPath']!));
      } catch (e) {
        debugPrint("Error playing audio: $e");
      }
    }
  }

  void _selectTrack(int index) async {
    setState(() {
      _activeTrackIndex = index;
    });
    final activeTrack = _tracks[_activeTrackIndex];
    try {
      await _audioPlayer.play(AssetSource(activeTrack['assetPath']!));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void _nextTrack() {
    int nextIndex = (_activeTrackIndex + 1) % _tracks.length;
    _selectTrack(nextIndex);
  }

  void _prevTrack() {
    int prevIndex = (_activeTrackIndex - 1 + _tracks.length) % _tracks.length;
    _selectTrack(prevIndex);
  }

  String _formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int remainingSeconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 950;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      drawer: isMobile ? _buildMobileDrawer() : null,
      body: Stack(
        children: [
          // Single page scrollable content
          SelectionArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildHeroSection(size, isMobile),
                  _buildAboutSection(size, isMobile),
                  _buildServicesSection(size, isMobile),
                  _buildMediaShowcaseSection(size, isMobile),
                  _buildWhyChooseSection(size, isMobile),
                  _buildBookingSection(size, isMobile),
                  _buildFooterSection(size, isMobile),
                ],
              ),
            ),
          ),
          
          // Sticky glassmorphic top navigation bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildStickyNavbar(isMobile),
          ),
        ],
      ),
    );
  }

  // --- Sticky Navigation Bar ---
  Widget _buildStickyNavbar(bool isMobile) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFFD4AF37),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo / Brand
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _scrollToSection(SectionType.home),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CHEB REDOUANE',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                      color: const Color(0xFFD4AF37),
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'TLEMCANI HERITAGE',
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: isMobile ? 9 : 11,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Navigation Menu Items
          if (!isMobile)
            Row(
              children: [
                _buildNavItem(SectionType.home, 'Accueil'),
                _buildNavItem(SectionType.about, 'À Propos'),
                _buildNavItem(SectionType.services, 'Prestations'),
                _buildNavItem(SectionType.media, 'Musique & Galerie'),
                _buildNavItem(SectionType.whyChoose, 'Engagements'),
                _buildNavItem(SectionType.contact, 'Contact'),
                const SizedBox(width: 16),
                _buildBookCTAButton(),
              ],
            )
          else
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Color(0xFFD4AF37), size: 28),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(SectionType section, String label) {
    final isActive = _activeSection == section;
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: () => _scrollToSection(section),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                      color: isActive 
                          ? const Color(0xFFD4AF37) 
                          : (isHovered ? const Color(0xFFD4AF37).withOpacity(0.8) : Colors.white),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: isActive ? 24 : (isHovered ? 16 : 0),
                    color: const Color(0xFFD4AF37),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookCTAButton() {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: OutlinedButton(
            onPressed: () => _scrollToSection(SectionType.contact),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: const Color(0xFFD4AF37),
                width: isHovered ? 2 : 1.5,
              ),
              backgroundColor: isHovered 
                  ? const Color(0xFFD4AF37) 
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Réserver un Événement',
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontWeight: FontWeight.bold,
                color: isHovered ? const Color(0xFF0A1128) : const Color(0xFFD4AF37),
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0A1128),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFD4AF37), width: 1),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'CHEB REDOUANE',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFFD4AF37),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PATRIMOINE ALGÉRIEN',
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(SectionType.home, Icons.home, 'Accueil'),
                _buildDrawerItem(SectionType.about, Icons.person, 'À Propos'),
                _buildDrawerItem(SectionType.services, Icons.star, 'Prestations'),
                _buildDrawerItem(SectionType.media, Icons.audiotrack, 'Musique & Galerie'),
                _buildDrawerItem(SectionType.whyChoose, Icons.check_circle, 'Engagements'),
                _buildDrawerItem(SectionType.contact, Icons.event, 'Contact / Réservation'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              '© ${DateTime.now().year} Cheb Redouane Tlemcani',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(SectionType section, IconData icon, String label) {
    final isActive = _activeSection == section;
    return ListTile(
      leading: Icon(icon, color: isActive ? const Color(0xFFD4AF37) : Colors.white70),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? const Color(0xFFD4AF37) : Colors.white,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
        ),
      ),
      selected: isActive,
      onTap: () {
        Navigator.pop(context); // Close drawer
        _scrollToSection(section);
      },
    );
  }

  // --- 1. Hero Section ---
  Widget _buildHeroSection(Size size, bool isMobile) {
    return Container(
      key: _sectionKeys[SectionType.home],
      height: size.height,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero_performance.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                // High-quality fallback dark gradient if image is not loaded
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF030712),
                        Color(0xFF0A1128),
                        Color(0xFF1E1E2F),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Midnight blue/charcoal overlay to maintain design language and high-contrast readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A1128).withOpacity(0.6),
                    const Color(0xFF0A1128).withOpacity(0.85),
                    const Color(0xFFFAF9F6), // Blend smoothly into About section (light background)
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          
          // Hero content
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              margin: const EdgeInsets.only(top: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Elegant Golden Tagline
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                    ),
                    child: const Text(
                      'HÉRITAGE MUSICAL & HAWZI DE TLEMCEN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Main Headline
                  Text(
                    'Vivez la Magie de la Musique Algérienne Authentique',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: isMobile ? 32 : 54,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Subtitle
                  Text(
                    'Mariages, Anniversaires, Événements Privés & Concerts Publics avec Cheb Redouane Tlemcani. Une musique élégante, festive et 100% respectueuse des traditions familiales.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isMobile ? 15 : 19,
                      height: 1.6,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Dual CTA Buttons
                  Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      // Primary CTA
                      ElevatedButton(
                        onPressed: () => _scrollToSection(SectionType.contact),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: const Color(0xFF0A1128),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 5,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Réserver Votre Événement',
                              style: TextStyle(
                                fontFamily: 'sans-serif',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                      
                      // Secondary CTA
                      OutlinedButton(
                        onPressed: () => _scrollToSection(SectionType.media),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.08),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Écouter les Démos',
                              style: TextStyle(
                                fontFamily: 'sans-serif',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.play_circle_outline, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. About Section ---
  Widget _buildAboutSection(Size size, bool isMobile) {
    return Container(
      key: _sectionKeys[SectionType.about],
      color: const Color(0xFFFAF9F6),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Section Header
              const Text(
                'L’Artiste & Son Héritage',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cheb Redouane Tlemcani',
                style: TextStyle(
                  fontFamily: 'serif',
                  color: Color(0xFF0A1128),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 2,
                width: 80,
                color: const Color(0xFFD4AF37),
              ),
              const SizedBox(height: 60),
              
              // Responsive Bio Layout
              isMobile 
                ? Column(
                    children: [
                      _buildAboutPortrait(),
                      const SizedBox(height: 48),
                      _buildAboutText(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 5, child: _buildAboutPortrait()),
                      const SizedBox(width: 64),
                      Expanded(flex: 6, child: _buildAboutText()),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutPortrait() {
    return Container(
      height: 420,
      width: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background elegant gold frame offset
          Positioned(
            top: 20,
            left: 20,
            right: -20,
            bottom: -20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 2,
                ),
              ),
            ),
          ),
          // Actual Profile Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/redouane_portrait.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Luxury gold-navy color box fallback
                return Container(
                  color: const Color(0xFF0A1128),
                  child: const Center(
                    child: Icon(Icons.music_note, color: Color(0xFFD4AF37), size: 64),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'La Voix de la Tradition et du Raffinement',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A1128),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Originaire de la magnifique cité de Tlemcen, haut lieu d’art et d’histoire, Cheb Redouane Tlemcani perpétue avec passion le riche héritage du Hawzi et du Chaabi algérien. Fort d’une solide expérience des scènes familiales et des scènes publiques, il a su s’imposer comme une référence incontournable pour animer les plus beaux moments de vie.',
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 16,
            height: 1.7,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Cheb Redouane propose un répertoire propre, noble et profondément familial. Il sélectionne chaque morceau avec attention pour garantir une ambiance à la fois festive, entraînante et respectueuse de toutes les générations présentes.',
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 16,
            height: 1.7,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 36),
        
        // Mini Stats Cards
        Row(
          children: [
            _buildStatItem('15+', 'Ans de Carrière'),
            const SizedBox(width: 24),
            _buildStatItem('500+', 'Fêtes Célébrées'),
            const SizedBox(width: 24),
            _buildStatItem('100%', 'Propre & Familial'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontFamily: 'serif',
                color: Color(0xFFD4AF37),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'sans-serif',
                color: Color(0xFF4A4A4A),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Services Grid Section ---
  Widget _buildServicesSection(Size size, bool isMobile) {
    final double paddingVal = isMobile ? 24.0 : 64.0;
    return Container(
      key: _sectionKeys[SectionType.services],
      color: const Color(0xFF0F162A), // Luxury Dark Charcoal/Navy Background
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: paddingVal, vertical: 100.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Section Header
              const Text(
                'Des Prestations Sur Mesure',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pour Vos Plus Beaux Moments',
                style: TextStyle(
                  fontFamily: 'serif',
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 2,
                width: 80,
                color: const Color(0xFFD4AF37),
              ),
              const SizedBox(height: 64),
              
              // Grid of 4 Interactive Cards
              isMobile 
                ? Column(
                    children: [
                      _buildServiceCard(
                        Icons.favorite,
                        'Mariages (Mariages Algériens)',
                        'Une ambiance chaleureuse et inoubliable pour votre grand jour. Du Hawzi rythmé aux chansons de noces traditionnelles, nous créons la bande-son parfaite pour célébrer votre union.',
                      ),
                      const SizedBox(height: 24),
                      _buildServiceCard(
                        Icons.cake,
                        'Anniversaires',
                        'Célébrez vos bougies et celles de vos proches dans une ambiance festive et conviviale. Un répertoire joyeux adapté à tous vos invités.',
                      ),
                      const SizedBox(height: 24),
                      _buildServiceCard(
                        Icons.vpn_key,
                        'Événements Privés / VIP',
                        'Une prestation haut de gamme sur mesure pour vos dîners professionnels, réceptions familiales exclusives ou soirées restreintes.',
                      ),
                      const SizedBox(height: 24),
                      _buildServiceCard(
                        Icons.music_video,
                        'Concerts Publics & Festivals',
                        'Un partage culturel intense sur scène. Des représentations dynamiques valorisant le patrimoine musical algérien face à un large public.',
                      ),
                    ],
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      double cardWidth = (constraints.maxWidth - 24) / 2;
                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          Container(
                            width: cardWidth,
                            child: _buildServiceCard(
                              Icons.favorite,
                              'Mariages (Mariages Algériens)',
                              'Une ambiance chaleureuse et inoubliable pour votre grand jour. Du Hawzi rythmé aux chansons de noces traditionnelles, nous créons la bande-son de votre union.',
                            ),
                          ),
                          Container(
                            width: cardWidth,
                            child: _buildServiceCard(
                              Icons.cake,
                              'Anniversaires',
                              'Célébrez vos bougies et celles de vos proches dans une ambiance festive et conviviale. Un répertoire joyeux et rythmé adapté à tous vos invités.',
                            ),
                          ),
                          Container(
                            width: cardWidth,
                            child: _buildServiceCard(
                              Icons.vpn_key,
                              'Événements Privés / VIP',
                              'Une prestation haut de gamme sur mesure pour vos dîners professionnels, réceptions familiales exclusives ou soirées restreintes.',
                            ),
                          ),
                          Container(
                            width: cardWidth,
                            child: _buildServiceCard(
                              Icons.music_video,
                              'Concerts Publics & Festivals',
                              'Un partage culturel intense sur scène. Des représentations dynamiques valorisant le patrimoine musical algérien face à un large public.',
                            ),
                          ),
                        ],
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
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            transform: isHovered 
                ? (Matrix4.identity()..translate(0, -8, 0)..scale(1.02))
                : Matrix4.identity(),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isHovered ? const Color(0xFFD4AF37) : const Color(0xFF334155),
                width: 1.5,
              ),
              boxShadow: [
                if (isHovered)
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                    color: isHovered 
                        ? const Color(0xFFD4AF37) 
                        : const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    icon, 
                    color: isHovered ? const Color(0xFF0F162A) : const Color(0xFFD4AF37),
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
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 4. Audio & Media Showcase Section ---
  Widget _buildMediaShowcaseSection(Size size, bool isMobile) {
    return Container(
      key: _sectionKeys[SectionType.media],
      color: const Color(0xFFFAF9F6), // Warm cream background
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Section Header
              const Text(
                'Showcase Média',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Galerie & Écoute de Démos',
                style: TextStyle(
                  fontFamily: 'serif',
                  color: Color(0xFF0A1128),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 2,
                width: 80,
                color: const Color(0xFFD4AF37),
              ),
              const SizedBox(height: 60),

              // Responsive layout split: Player & Photos
              isMobile 
                ? Column(
                    children: [
                      _buildAudioPlayer(isMobile),
                      const SizedBox(height: 64),
                      _buildPhotoGallery(isMobile),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: _buildAudioPlayer(isMobile)),
                      const SizedBox(width: 48),
                      Expanded(flex: 6, child: _buildPhotoGallery(isMobile)),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(bool isMobile) {
    final activeTrack = _tracks[_activeTrackIndex];
    double maxSeconds = _duration.inSeconds > 0 
        ? _duration.inSeconds.toDouble() 
        : double.parse(activeTrack['seconds']!);
    double currentSeconds = _position.inSeconds.toDouble();
    if (currentSeconds > maxSeconds) {
      currentSeconds = maxSeconds;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128), // Luxury dark navy
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Header Title
          Row(
            children: [
              const Icon(Icons.volume_up, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 8),
              Text(
                'LECTEUR AUDIO DÉMO',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 2,
                  color: const Color(0xFFD4AF37).withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Simulated Album Art & Active Track Info
          Row(
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Audio animated ripple simulation when playing
                      if (_isPlaying)
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                          ),
                        ),
                      const Icon(Icons.music_note, color: Color(0xFFD4AF37), size: 32),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeTrack['title']!,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activeTrack['genre']!,
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Playback timeline progress bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFD4AF37),
              inactiveTrackColor: Colors.white24,
              thumbColor: const Color(0xFFD4AF37),
              trackHeight: 3.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
            ),
            child: Slider(
              value: currentSeconds,
              min: 0.0,
              max: maxSeconds,
              onChanged: (val) {
                _audioPlayer.seek(Duration(seconds: val.toInt()));
              },
            ),
          ),

          // Timers below timeline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
                Text(
                  _duration.inSeconds > 0 ? _formatDuration(_duration) : activeTrack['duration']!,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Primary Controls Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 28),
                onPressed: _prevTrack,
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4AF37),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: const Color(0xFF0A1128),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
                onPressed: _nextTrack,
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // Tracks Playlist
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tracks.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
            itemBuilder: (context, index) {
              final isCurrent = index == _activeTrackIndex;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                dense: true,
                leading: Icon(
                  isCurrent && _isPlaying ? Icons.volume_up : Icons.play_arrow_outlined,
                  color: isCurrent ? const Color(0xFFD4AF37) : Colors.white60,
                  size: 18,
                ),
                title: Text(
                  _tracks[index]['title']!,
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: isCurrent ? const Color(0xFFD4AF37) : Colors.white,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                trailing: Text(
                  isCurrent && _duration.inSeconds > 0
                      ? _formatDuration(_duration)
                      : _tracks[index]['duration']!,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                onTap: () => _selectTrack(index),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gallery title
        const Text(
          'PHOTOS DE PRESTATIONS',
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 2,
            color: Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Aperçu de nos prestations en direct lors des plus prestigieuses cérémonies.',
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 15,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 32),

        // Photo Grid (4 images representing different contexts)
        LayoutBuilder(
          builder: (context, constraints) {
            double sizeVal = (constraints.maxWidth - 16) / 2;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildGalleryImage('Mariage Célébration', 'assets/images/wedding_performance.png', sizeVal),
                _buildGalleryImage('Tradition Tlemcen', 'assets/images/tlemcen_heritage.png', sizeVal),
                _buildGalleryImage('Concert sur Scène', 'assets/images/hero_performance.png', sizeVal),
                _buildGalleryImage('Portrait Privé', 'assets/images/redouane_portrait.png', sizeVal),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGalleryImage(String label, String imagePath, double size) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Actual Image
                Positioned.fill(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF0F162A),
                        child: const Center(
                          child: Icon(Icons.image, color: Color(0xFFD4AF37), size: 40),
                        ),
                      );
                    },
                  ),
                ),
                // Hover Overlay with Gold text & zoom effect
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    color: isHovered 
                        ? const Color(0xFF0A1128).withOpacity(0.85) 
                        : Colors.transparent,
                    child: isHovered 
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.zoom_in, color: Color(0xFFD4AF37), size: 32),
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
          ),
        );
      },
    );
  }

  // --- 5. Why Choose Section ---
  Widget _buildWhyChooseSection(Size size, bool isMobile) {
    return Container(
      key: _sectionKeys[SectionType.whyChoose],
      color: const Color(0xFF0A1128), // Luxury deep midnight blue
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Section Header
              const Text(
                'Pourquoi Choisir Cheb Redouane ?',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nos Engagements Qualité',
                style: TextStyle(
                  fontFamily: 'serif',
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 2,
                width: 80,
                color: const Color(0xFFD4AF37),
              ),
              const SizedBox(height: 64),

              // 3 Pillars row / column layout
              isMobile 
                ? Column(
                    children: [
                      _buildPillarItem(
                        Icons.family_restroom,
                        '100% Propre & Familial',
                        'Une sélection de morceaux entièrement adaptés aux réunions familiales. Respect total des valeurs culturelles et absence de termes inconvenants.',
                      ),
                      const SizedBox(height: 48),
                      _buildPillarItem(
                        Icons.library_music,
                        'Répertoire Traditionnel Riche',
                        'Maîtrise authentique du Hawzi de Tlemcen, du Chaabi algérois, ainsi que des classiques populaires célébrant notre patrimoine.',
                      ),
                      const SizedBox(height: 48),
                      _buildPillarItem(
                        Icons.assignment_turned_in,
                        'Professionnalisme & Ponctualité',
                        'Respect rigoureux des horaires, matériel de sonorisation professionnel haut de gamme et collaboration étroite avec vos prestataires.',
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildPillarItem(
                          Icons.family_restroom,
                          '100% Propre & Familial',
                          'Une sélection de morceaux entièrement adaptés aux réunions familiales. Respect total des valeurs culturelles et absence de termes inconvenants.',
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: _buildPillarItem(
                          Icons.library_music,
                          'Répertoire Traditionnel Riche',
                          'Maîtrise authentique du Hawzi de Tlemcen, du Chaabi algérois, ainsi que des classiques populaires célébrant notre patrimoine.',
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: _buildPillarItem(
                          Icons.assignment_turned_in,
                          'Professionnalisme & Ponctualité',
                          'Respect rigoureux des horaires, matériel de sonorisation professionnel haut de gamme et collaboration étroite avec vos prestataires.',
                        ),
                      ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillarItem(IconData icon, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 28),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
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
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'sans-serif',
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // --- 6. Booking & Contact Section ---
  Widget _buildBookingSection(Size size, bool isMobile) {
    return Container(
      key: _sectionKeys[SectionType.contact],
      color: const Color(0xFFFAF9F6), // Light cream
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Section Header
              const Text(
                'Planifiez Votre Événement',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Formulaire de Réservation',
                style: TextStyle(
                  fontFamily: 'serif',
                  color: Color(0xFF0A1128),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 2,
                width: 80,
                color: const Color(0xFFD4AF37),
              ),
              const SizedBox(height: 48),

              // Booking Card Form
              const BookingFormWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Footer Section ---
  Widget _buildFooterSection(Size size, bool isMobile) {
    return Container(
      color: const Color(0xFF050814), // Ultra dark midnight blue
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 64.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              isMobile 
                ? Column(
                    children: [
                      _buildFooterBrand(),
                      const SizedBox(height: 40),
                      _buildFooterContacts(),
                      const SizedBox(height: 40),
                      _buildFooterSocials(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 4, child: _buildFooterBrand()),
                      const SizedBox(width: 32),
                      Expanded(flex: 4, child: _buildFooterContacts()),
                      const SizedBox(width: 32),
                      Expanded(flex: 3, child: _buildFooterSocials()),
                    ],
                  ),
              const SizedBox(height: 48),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© ${DateTime.now().year} Cheb Redouane Tlemcani. Tous Droits Réservés.',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                  ),
                  if (!isMobile)
                    Text(
                      'Créé avec excellence pour le patrimoine musical.',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHEB REDOUANE',
          style: TextStyle(
            fontFamily: 'serif',
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 2,
          ),
        ),
        const Text(
          'TLEMCANI HERITAGE',
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 11,
            color: Colors.white54,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Prestateur musical d\'exception pour vos plus grandes fêtes de familles. Une ambiance digne de vos traditions.',
          style: TextStyle(
            fontFamily: 'sans-serif',
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONTACT & MANAGEMENT',
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),
        _buildFooterContactLink(Icons.phone, '+213 (0) 555 12 34 56'),
        const SizedBox(height: 12),
        _buildFooterContactLink(Icons.email, 'contact@chebredouane-tlemcani.com'),
        const SizedBox(height: 12),
        _buildFooterContactLink(Icons.location_on, 'Tlemcen, Algérie'),
      ],
    );
  }

  Widget _buildFooterContactLink(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 18),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'sans-serif',
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterSocials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SUIVEZ L\'ARTISTE',
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _buildSocialIconButton(Icons.music_video, 'YouTube'), // Mocks
            const SizedBox(width: 16),
            _buildSocialIconButton(Icons.camera_alt, 'Instagram'),
            const SizedBox(width: 16),
            _buildSocialIconButton(Icons.tiktok, 'TikTok'),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Disponible sur toute l\'Algérie (Alger, Oran, Constantine, Tlemcen, Sidi Bel Abbès...) et à l\'étranger.',
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: 12,
            color: Colors.white.withOpacity(0.4),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIconButton(IconData icon, String tooltip) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: isHovered ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.05),
              border: Border.all(
                color: isHovered ? const Color(0xFFD4AF37) : Colors.white24,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconButton(
              icon: Icon(icon, color: isHovered ? const Color(0xFF050814) : Colors.white, size: 20),
              tooltip: tooltip,
              onPressed: () {
                // Mock social navigation message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFFD4AF37),
                    content: Text(
                      'Redirection vers le compte $tooltip officiel de Cheb Redouane...',
                      style: const TextStyle(color: Color(0xFF0A1128), fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// --- Stateful Form Widget for booking ---
class BookingFormWidget extends StatefulWidget {
  const BookingFormWidget({super.key});

  @override
  State<BookingFormWidget> createState() => _BookingFormWidgetState();
}

class _BookingFormWidgetState extends State<BookingFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _requestsController = TextEditingController();

  String _eventType = 'Mariage';
  DateTime? _selectedDate;

  final List<String> _eventTypes = [
    'Mariage',
    'Anniversaire',
    'Soirée Privée / VIP',
    'Concert Public / Festival',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _requestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0A1128),
              onPrimary: Color(0xFFD4AF37),
              onSurface: Color(0xFF0A1128),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD4AF37),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'Veuillez sélectionner une date pour l\'événement.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
        return;
      }
      
      // Success Dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: const Color(0xFF0A1128),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFFD4AF37),
                    size: 64,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Demande de Réservation Envoyée !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Merci ${_nameController.text}. Votre demande pour un(e) "$_eventType" le ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} à ${_locationController.text} est bien enregistrée.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'sans-serif',
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Le management de Cheb Redouane vous contactera sous 24h au numéro fourni.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'sans-serif',
                      color: Color(0xFFD4AF37),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _resetForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF0A1128),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Fermer',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _phoneController.clear();
    _locationController.clear();
    _requestsController.clear();
    setState(() {
      _selectedDate = null;
      _eventType = 'Mariage';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128), // Luxury dark navy block
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle header inside card
            const Center(
              child: Text(
                'PRENEZ DIRECTEMENT CONTACT POUR CONSTRUIRE VOTRE CÉRÉMONIE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Name Field
            _buildTextField(
              controller: _nameController,
              label: 'Nom Complet',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir votre nom complet';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Phone Field
            _buildTextField(
              controller: _phoneController,
              label: 'Numéro de Téléphone',
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
              helperText: 'Ex: 0555123456 ou +213...',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez saisir votre numéro de téléphone';
                }
                // Basic Algerian phone regex or generic format check
                final phoneRegExp = RegExp(r'^(\+213|0)(5|6|7)[0-9]{8}$');
                final generalPhoneRegExp = RegExp(r'^\+?[0-9\s\-]{8,15}$');
                if (!phoneRegExp.hasMatch(value.replaceAll(' ', '')) && 
                    !generalPhoneRegExp.hasMatch(value)) {
                  return 'Veuillez saisir un numéro de téléphone valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Responsive fields row: Event Type and Date
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 500) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildEventTypeDropdown()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildDatePickerField(context)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildEventTypeDropdown(),
                      const SizedBox(height: 24),
                      _buildDatePickerField(context),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Location Field
            _buildTextField(
              controller: _locationController,
              label: 'Lieu de l\'Événement (Ville, Commune)',
              icon: Icons.location_on_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Veuillez préciser le lieu de l\'événement';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Requests / Special Notes Field
            _buildTextField(
              controller: _requestsController,
              label: 'Demandes Particulières / Titres Souhaités',
              icon: Icons.notes_outlined,
              maxLines: 4,
            ),
            const SizedBox(height: 40),

            // Form Submit Button
            Center(
              child: StatefulBuilder(
                builder: (context, setState) {
                  bool isHovered = false;
                  return MouseRegion(
                    onEnter: (_) => setState(() => isHovered = true),
                    onExit: (_) => setState(() => isHovered = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: const Color(0xFF0A1128),
                          elevation: isHovered ? 8 : 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Envoyer la Demande de Réservation',
                              style: TextStyle(
                                fontFamily: 'sans-serif',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.send, size: 18),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontFamily: 'sans-serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            helperText: helperText,
            helperStyle: const TextStyle(color: Colors.white38),
            prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
            filled: true,
            fillColor: const Color(0xFF1E293B).withOpacity(0.4),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24, width: 1),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildEventTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type d\'Événement',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontFamily: 'sans-serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _eventType,
          dropdownColor: const Color(0xFF0A1128),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.star_border, color: Color(0xFFD4AF37)),
            filled: true,
            fillColor: const Color(0xFF1E293B).withOpacity(0.4),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24, width: 1),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
            ),
          ),
          items: _eventTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _eventType = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date de l\'Événement',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontFamily: 'sans-serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_month, color: Color(0xFFD4AF37)),
              filled: true,
              fillColor: const Color(0xFF1E293B).withOpacity(0.4),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24, width: 1),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
              ),
            ),
            child: Text(
              _selectedDate == null
                  ? 'Sélectionner une Date'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              style: TextStyle(
                color: _selectedDate == null ? Colors.white38 : Colors.white,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/track_model.dart';
import '../../models/service_model.dart';
import '../../models/stat_model.dart';
import '../../models/pillar_model.dart';
import 'app_assets.dart';

/// Centralized data collections for tracks, services, stats, and quality pillars
abstract class AppData {
  /// Initial Audio Track Playlist
  static const List<TrackModel> tracks = [
    TrackModel(
      title: 'Medley Tlemcani (Live)',
      genre: 'Hawzi Traditionnel',
      duration: '03:45',
      seconds: '225',
      assetPath: AppAssets.trackMedleyTlemcani,
    ),
    TrackModel(
      title: 'Wedding Celebration Live Set',
      genre: 'Chaabi & Ambiance Mariage',
      duration: '05:12',
      seconds: '312',
      assetPath: AppAssets.trackWeddingLiveSet,
    ),
    TrackModel(
      title: 'Ghorba & Nostalgie',
      genre: 'Hawzi Moderne',
      duration: '04:20',
      seconds: '260',
      assetPath: AppAssets.trackGhorbaNostalgie,
    ),
    TrackModel(
      title: 'Héritage Andalou (Acoustique)',
      genre: 'Classique Tlemcen',
      duration: '06:05',
      seconds: '365',
      assetPath: AppAssets.trackHeritageAndalou,
    ),
  ];

  /// Career key statistics badges
  static const List<StatModel> stats = [
    StatModel(count: '15+', label: 'Ans de Carrière'),
    StatModel(count: '500+', label: 'Fêtes Célébrées'),
    StatModel(count: '100%', label: 'Propre & Familial'),
  ];

  /// Services Offered Grid Data
  static const List<ServiceModel> services = [
    ServiceModel(
      icon: Icons.favorite,
      title: 'Mariages (Mariages Algériens)',
      description:
          'Une ambiance chaleureuse et inoubliable pour votre grand jour. Du Hawzi rythmé aux chansons de noces traditionnelles, nous créons la bande-son de votre union.',
    ),
    ServiceModel(
      icon: Icons.cake,
      title: 'Anniversaires',
      description:
          'Célébrez vos bougies et celles de vos proches dans une ambiance festive et conviviale. Un répertoire joyeux et rythmé adapté à tous vos invités.',
    ),
    ServiceModel(
      icon: Icons.vpn_key,
      title: 'Événements Privés / VIP',
      description:
          'Une prestation haut de gamme sur mesure pour vos dîners professionnels, réceptions familiales exclusives ou soirées restreintes.',
    ),
    ServiceModel(
      icon: Icons.music_video,
      title: 'Concerts Publics & Festivals',
      description:
          'Un partage culturel intense sur scène. Des représentations dynamiques valorisant le patrimoine musical algérien face à un large public.',
    ),
  ];

  /// Quality Commitment Pillars
  static const List<PillarModel> pillars = [
    PillarModel(
      icon: Icons.family_restroom,
      title: '100% Propre & Familial',
      description:
          'Une sélection de morceaux entièrement adaptés aux réunions familiales. Respect total des valeurs culturelles et absence de termes inconvenants.',
    ),
    PillarModel(
      icon: Icons.library_music,
      title: 'Répertoire Traditionnel Riche',
      description:
          'Maîtrise authentique du Hawzi de Tlemcen, du Chaabi algérois, ainsi que des classiques populaires célébrant notre patrimoine.',
    ),
    PillarModel(
      icon: Icons.assignment_turned_in,
      title: 'Professionnalisme & Ponctualité',
      description:
          'Respect rigoureux des horaires, matériel de sonorisation professionnel haut de gamme et collaboration étroite avec vos prestataires.',
    ),
  ];
}

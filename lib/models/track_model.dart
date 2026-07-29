/// Model class for an audio demo track
class TrackModel {
  final String title;
  final String genre;
  final String duration;
  final String seconds;
  final String assetPath;

  const TrackModel({
    required this.title,
    required this.genre,
    required this.duration,
    required this.seconds,
    required this.assetPath,
  });

  /// Factory helper from Map structure
  factory TrackModel.fromMap(Map<String, String> map) {
    return TrackModel(
      title: map['title'] ?? '',
      genre: map['genre'] ?? '',
      duration: map['duration'] ?? '',
      seconds: map['seconds'] ?? '0',
      assetPath: map['assetPath'] ?? '',
    );
  }

  /// Convert to Map representation
  Map<String, String> toMap() {
    return {
      'title': title,
      'genre': genre,
      'duration': duration,
      'seconds': seconds,
      'assetPath': assetPath,
    };
  }
}

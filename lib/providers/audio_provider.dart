import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../core/constants/app_data.dart';
import '../models/track_model.dart';

/// Immutable State representing Audio Player state
class AudioState {
  final List<TrackModel> tracks;
  final int activeTrackIndex;
  final bool isPlaying;
  final bool isLoading;
  final Duration duration;
  final Duration position;
  final double volume;
  final bool isMuted;
  final String selectedGenre;
  final String searchQuery;
  final bool isRepeat;

  const AudioState({
    required this.tracks,
    this.activeTrackIndex = 0,
    this.isPlaying = false,
    this.isLoading = false,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.volume = 1.0,
    this.isMuted = false,
    this.selectedGenre = 'Tous',
    this.searchQuery = '',
    this.isRepeat = false,
  });

  TrackModel get activeTrack =>
      tracks.isNotEmpty && activeTrackIndex < tracks.length
          ? tracks[activeTrackIndex]
          : (tracks.isNotEmpty ? tracks.first : AppData.tracks.first);

  AudioState copyWith({
    List<TrackModel>? tracks,
    int? activeTrackIndex,
    bool? isPlaying,
    bool? isLoading,
    Duration? duration,
    Duration? position,
    double? volume,
    bool? isMuted,
    String? selectedGenre,
    String? searchQuery,
    bool? isRepeat,
  }) {
    return AudioState(
      tracks: tracks ?? this.tracks,
      activeTrackIndex: activeTrackIndex ?? this.activeTrackIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      searchQuery: searchQuery ?? this.searchQuery,
      isRepeat: isRepeat ?? this.isRepeat,
    );
  }
}

/// Riverpod Notifier for handling Audio Playback & Filtering
class AudioNotifier extends StateNotifier<AudioState> {
  late final AudioPlayer _audioPlayer;
  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _completeSub;

  AudioNotifier() : super(AudioState(tracks: AppData.tracks)) {
    _initAudio();
  }

  void _initAudio() {
    _audioPlayer = AudioPlayer();

    _durationSub = _audioPlayer.onDurationChanged.listen((dur) {
      state = state.copyWith(duration: dur);
    });

    _positionSub = _audioPlayer.onPositionChanged.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _stateSub = _audioPlayer.onPlayerStateChanged.listen((pState) {
      state = state.copyWith(
        isPlaying: pState == PlayerState.playing,
        isLoading: pState == PlayerState.playing ? false : state.isLoading,
      );
    });

    _completeSub = _audioPlayer.onPlayerComplete.listen((_) {
      if (state.isRepeat) {
        _playCurrentTrack();
      } else {
        nextTrack();
      }
    });
  }

  Future<void> _playCurrentTrack() async {
    state = state.copyWith(isLoading: true);
    try {
      final track = state.activeTrack;
      await _audioPlayer
          .play(AssetSource(track.assetPath))
          .timeout(const Duration(seconds: 4), onTimeout: () {
        debugPrint("Audio play response pending for ${track.assetPath}");
      });
      state = state.copyWith(isPlaying: true, isLoading: false);
    } catch (e) {
      debugPrint("Error playing audio track: $e");
      state = state.copyWith(isLoading: false);
    } finally {
      if (state.isLoading) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      try {
        await _audioPlayer.pause();
      } catch (e) {
        debugPrint("Error pausing audio: $e");
      }
      state = state.copyWith(isPlaying: false);
    } else {
      await _playCurrentTrack();
    }
  }

  Future<void> selectTrack(int index) async {
    if (index < 0 || index >= state.tracks.length) return;
    state = state.copyWith(activeTrackIndex: index);
    await _playCurrentTrack();
  }

  Future<void> nextTrack() async {
    int next = (state.activeTrackIndex + 1) % state.tracks.length;
    await selectTrack(next);
  }

  Future<void> prevTrack() async {
    int prev =
        (state.activeTrackIndex - 1 + state.tracks.length) % state.tracks.length;
    await selectTrack(prev);
  }

  Future<void> seek(Duration pos) async {
    try {
      await _audioPlayer.seek(pos);
      state = state.copyWith(position: pos);
    } catch (e) {
      debugPrint("Error seeking audio: $e");
    }
  }

  Future<void> setVolume(double vol) async {
    state = state.copyWith(volume: vol, isMuted: vol == 0);
    try {
      await _audioPlayer.setVolume(vol);
    } catch (e) {
      debugPrint("Error setting volume: $e");
    }
  }

  Future<void> toggleMute() async {
    if (state.isMuted) {
      final newVol = state.volume > 0 ? state.volume : 1.0;
      state = state.copyWith(isMuted: false, volume: newVol);
      try {
        await _audioPlayer.setVolume(newVol);
      } catch (e) {
        debugPrint("Error unmuting audio: $e");
      }
    } else {
      state = state.copyWith(isMuted: true);
      try {
        await _audioPlayer.setVolume(0);
      } catch (e) {
        debugPrint("Error muting audio: $e");
      }
    }
  }

  void toggleRepeat() {
    state = state.copyWith(isRepeat: !state.isRepeat);
  }

  void filterByGenre(String genre) {
    state = state.copyWith(selectedGenre: genre);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  String formatDuration(Duration dur) {
    int minutes = dur.inMinutes;
    int seconds = dur.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Global Audio Riverpod State Provider
final audioProvider = StateNotifierProvider<AudioNotifier, AudioState>((ref) {
  return AudioNotifier();
});

/// Filtered tracks based on selected genre & search query
final filteredTracksProvider = Provider<List<TrackModel>>((ref) {
  final audioState = ref.watch(audioProvider);
  return audioState.tracks.where((track) {
    final matchesGenre = audioState.selectedGenre == 'Tous' ||
        track.genre.toLowerCase().contains(audioState.selectedGenre.toLowerCase());
    final matchesSearch = audioState.searchQuery.isEmpty ||
        track.title.toLowerCase().contains(audioState.searchQuery.toLowerCase()) ||
        track.genre.toLowerCase().contains(audioState.searchQuery.toLowerCase());
    return matchesGenre && matchesSearch;
  }).toList();
});

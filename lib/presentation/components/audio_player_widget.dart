import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/audio_provider.dart';
import '../../models/track_model.dart';

/// Spinning Andalusian Vinyl Record Widget
class SpinningVinyl extends StatefulWidget {
  final bool isPlaying;
  final bool isCompact;

  const SpinningVinyl({
    super.key,
    required this.isPlaying,
    required this.isCompact,
  });

  @override
  State<SpinningVinyl> createState() => _SpinningVinylState();
}

class _SpinningVinylState extends State<SpinningVinyl> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SpinningVinyl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isCompact ? 60.0 : 72.0;
    return RotationTransition(
      turns: _rotationController,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: const Color(0xFF080D1A),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: widget.isPlaying ? 0.35 : 0.1),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vinyl grooves
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 0.8),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 0.8),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white10, width: 0.8),
                ),
              ),
              // Golden Center Label
              Container(
                height: widget.isCompact ? 20.0 : 24.0,
                width: widget.isCompact ? 20.0 : 24.0,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.music_note,
                    color: AppColors.navy,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dynamic Gold Audio Waveform Visualizer Widget
class AudioWaveformVisualizer extends StatefulWidget {
  final bool isPlaying;

  const AudioWaveformVisualizer({
    super.key,
    required this.isPlaying,
  });

  @override
  State<AudioWaveformVisualizer> createState() => _AudioWaveformVisualizerState();
}

class _AudioWaveformVisualizerState extends State<AudioWaveformVisualizer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addListener(() {
        if (mounted && widget.isPlaying) {
          setState(() {});
        }
      });

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AudioWaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      width: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (index) {
          double val = widget.isPlaying
              ? (0.15 + (0.85 * (index % 2 == 0 ? _controller.value : (1.0 - _controller.value))))
              : 0.2;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 90),
            width: 3.5,
            height: 18 * val,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

/// Isolated Progress Timeline Slider (Rebuilds independently during playback)
class AudioProgressBar extends ConsumerWidget {
  const AudioProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(audioProvider.select((state) => state.position));
    final duration = ref.watch(audioProvider.select((state) => state.duration));
    final activeTrack = ref.watch(audioProvider.select((state) => state.activeTrack));
    final audioNotifier = ref.read(audioProvider.notifier);

    double maxSeconds = duration.inSeconds > 0
        ? duration.inSeconds.toDouble()
        : (double.tryParse(activeTrack.seconds) ?? 200.0);
    double currentSeconds = position.inSeconds.toDouble();
    if (currentSeconds > maxSeconds) {
      currentSeconds = maxSeconds;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.gold,
            inactiveTrackColor: Colors.white12,
            thumbColor: AppColors.gold,
            trackHeight: 3.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
          ),
          child: Slider(
            value: currentSeconds,
            min: 0.0,
            max: maxSeconds,
            onChanged: (val) {
              audioNotifier.seek(Duration(seconds: val.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                audioNotifier.formatDuration(position),
                style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'sans-serif'),
              ),
              Text(
                duration.inSeconds > 0
                    ? audioNotifier.formatDuration(duration)
                    : activeTrack.duration,
                style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'sans-serif'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fully Responsive & Premium Riverpod Audio Player Widget
class AudioPlayerWidget extends ConsumerWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredTracks = ref.watch(filteredTracksProvider);
    final audioNotifier = ref.read(audioProvider.notifier);
    final selectedGenre = ref.watch(audioProvider.select((state) => state.selectedGenre));

    final genres = ['Tous', 'Hawzi', 'Chaabi', 'Tlemcani', 'Sétifien'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        final paddingVal = isCompact ? 16.0 : 24.0;

        return Container(
          padding: EdgeInsets.all(paddingVal),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1626).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Controls bar
              const _AudioPlayerHeader(),
              const SizedBox(height: 20),

              // Active track card details
              _ActiveTrackCard(isCompact: isCompact),
              const SizedBox(height: 16),

              // Isolated progress bar
              const AudioProgressBar(),
              const SizedBox(height: 16),

              // Main Playback Controls
              _AudioPlaybackControls(isCompact: isCompact),
              const SizedBox(height: 20),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 16),

              // Genre selection chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: genres.map((genre) {
                    final isSelected = selectedGenre == genre;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(genre),
                        selected: isSelected,
                        selectedColor: AppColors.gold,
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.06),
                        labelStyle: TextStyle(
                          fontFamily: 'sans-serif',
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color:  AppColors.navy,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.gold : Colors.white12,
                          ),
                        ),
                        onSelected: (_) => audioNotifier.filterByGenre(genre),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Track Search Box
              TextField(
                onChanged: (val) => audioNotifier.setSearchQuery(val),
                style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'sans-serif'),
                decoration: InputDecoration(
                  hintText: 'Rechercher une chanson...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13, fontFamily: 'sans-serif'),
                  prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Playlist track rows
              filteredTracks.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'Aucun morceau trouvé',
                          style: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'sans-serif'),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTracks.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (context, index) {
                        final track = filteredTracks[index];
                        return _AudioTrackRowItem(track: track);
                      },
                    ),
            ],
          ),
        );
      },
    );
  }
}

/// Header bar inside player containing state and titles
class _AudioPlayerHeader extends ConsumerWidget {
  const _AudioPlayerHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(audioProvider.select((state) => state.isPlaying));
    final isLoading = ref.watch(audioProvider.select((state) => state.isLoading));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.equalizer, color: AppColors.gold, size: 20),
            const SizedBox(width: 8),
            Text(
              AppStrings.playerHeader,
              style: TextStyle(
                fontFamily: 'sans-serif',
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.5,
                color: AppColors.gold.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isPlaying ? AppColors.gold.withValues(alpha: 0.15) : Colors.white10,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPlaying ? AppColors.gold : Colors.white24,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AudioWaveformVisualizer(isPlaying: isPlaying),
              const SizedBox(width: 8),
              Text(
                isLoading
                    ? 'CHARGEMENT...'
                    : (isPlaying ? 'EN LECTURE' : 'EN PAUSE'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isPlaying ? AppColors.gold : Colors.white60,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Active Album Art & Title Panel
class _ActiveTrackCard extends ConsumerWidget {
  final bool isCompact;

  const _ActiveTrackCard({required this.isCompact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTrack = ref.watch(audioProvider.select((state) => state.activeTrack));
    final isPlaying = ref.watch(audioProvider.select((state) => state.isPlaying));
    final isRepeat = ref.watch(audioProvider.select((state) => state.isRepeat));

    return Row(
      children: [
        // Album art spinning vinyl disc
        SpinningVinyl(isPlaying: isPlaying, isCompact: isCompact),
        const SizedBox(width: 16),

        // Track Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activeTrack.title,
                style: TextStyle(
                  fontFamily: 'serif',
                  color: Colors.white,
                  fontSize: isCompact ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      activeTrack.genre,
                      style: TextStyle(
                        fontFamily: 'sans-serif',
                        color: AppColors.gold.withValues(alpha: 0.95),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isRepeat) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'RÉPÉTER',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Control bar for play buttons, volume control
class _AudioPlaybackControls extends ConsumerWidget {
  final bool isCompact;

  const _AudioPlaybackControls({required this.isCompact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(audioProvider.select((state) => state.isPlaying));
    final isLoading = ref.watch(audioProvider.select((state) => state.isLoading));
    final isRepeat = ref.watch(audioProvider.select((state) => state.isRepeat));
    final isMuted = ref.watch(audioProvider.select((state) => state.isMuted));
    final volume = ref.watch(audioProvider.select((state) => state.volume));
    final audioNotifier = ref.read(audioProvider.notifier);

    final playButton = GestureDetector(
      onTap: () => audioNotifier.togglePlayPause(),
      child: Container(
        height: isCompact ? 48 : 52,
        width: isCompact ? 48 : 52,
        decoration: const BoxDecoration(
          color: AppColors.gold,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.gold,
              blurRadius: 10,
              spreadRadius: -2,
            ),
          ],
        ),
        child: isLoading
            ? Padding(
                padding: EdgeInsets.all(isCompact ? 12.0 : 14.0),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.navy),
                ),
              )
            : Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.navy,
                size: isCompact ? 28 : 30,
              ),
      ),
    );

    if (isCompact) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.repeat,
                  color: isRepeat ? AppColors.gold : Colors.white38,
                  size: 22,
                ),
                onPressed: () => audioNotifier.toggleRepeat(),
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 28),
                onPressed: () => audioNotifier.prevTrack(),
              ),
              playButton,
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
                onPressed: () => audioNotifier.nextTrack(),
              ),
              IconButton(
                icon: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: AppColors.gold,
                  size: 22,
                ),
                onPressed: () => audioNotifier.toggleMute(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.volume_down, color: Colors.white38, size: 16),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.gold,
                    inactiveTrackColor: Colors.white12,
                    thumbColor: AppColors.gold,
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.0),
                  ),
                  child: Slider(
                    value: isMuted ? 0.0 : volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (vol) => audioNotifier.setVolume(vol),
                  ),
                ),
              ),
              const Icon(Icons.volume_up, color: Colors.white38, size: 16),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        IconButton(
          icon: Icon(
            isMuted
                ? Icons.volume_off
                : (volume < 0.5 ? Icons.volume_down : Icons.volume_up),
            color: AppColors.gold,
            size: 20,
          ),
          onPressed: () => audioNotifier.toggleMute(),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 80),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.gold,
              inactiveTrackColor: Colors.white12,
              thumbColor: AppColors.gold,
              trackHeight: 2.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.0),
            ),
            child: Slider(
              value: isMuted ? 0.0 : volume,
              min: 0.0,
              max: 1.0,
              onChanged: (vol) => audioNotifier.setVolume(vol),
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 28),
          onPressed: () => audioNotifier.prevTrack(),
        ),
        const SizedBox(width: 12),
        playButton,
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
          onPressed: () => audioNotifier.nextTrack(),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            Icons.repeat,
            color: isRepeat ? AppColors.gold : Colors.white38,
            size: 22,
          ),
          onPressed: () => audioNotifier.toggleRepeat(),
        ),
      ],
    );
  }
}

/// Dynamic, independent row item for list of tracks
class _AudioTrackRowItem extends ConsumerWidget {
  final TrackModel track;

  const _AudioTrackRowItem({required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTrackIndex = ref.watch(audioProvider.select((state) => state.activeTrackIndex));
    final tracks = ref.watch(audioProvider.select((state) => state.tracks));
    final isPlaying = ref.watch(audioProvider.select((state) => state.isPlaying));
    final audioNotifier = ref.read(audioProvider.notifier);

    final originalIndex = tracks.indexOf(track);
    final isCurrent = originalIndex == activeTrackIndex;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.gold.withValues(alpha: 0.15) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCurrent && isPlaying ? Icons.volume_up : Icons.play_arrow_outlined,
            color: isCurrent ? AppColors.gold : Colors.white60,
            size: 18,
          ),
        ),
        title: Text(
          track.title,
          style: TextStyle(
            fontFamily: 'serif',
            color: isCurrent ? AppColors.gold : Colors.white,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w400,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          track.genre,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontFamily: 'sans-serif',
          ),
        ),
        trailing: Text(
          track.duration,
          style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'sans-serif'),
        ),
        onTap: () => audioNotifier.selectTrack(originalIndex),
      ),
    );
  }
}

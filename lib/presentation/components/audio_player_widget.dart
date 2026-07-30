import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/audio_provider.dart';

/// Fully Responsive & Premium Riverpod Audio Player Widget
class AudioPlayerWidget extends ConsumerWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final filteredTracks = ref.watch(filteredTracksProvider);
    final audioNotifier = ref.read(audioProvider.notifier);

    final activeTrack = audioState.activeTrack;
    double maxSeconds = audioState.duration.inSeconds > 0
        ? audioState.duration.inSeconds.toDouble()
        : (double.tryParse(activeTrack.seconds) ?? 200.0);
    double currentSeconds = audioState.position.inSeconds.toDouble();
    if (currentSeconds > maxSeconds) {
      currentSeconds = maxSeconds;
    }

    final genres = ['Tous', 'Hawzi', 'Chaabi', 'Tlemcani', 'Sétifien'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        final paddingVal = isCompact ? 16.0 : 24.0;

        return Container(
          padding: EdgeInsets.all(paddingVal),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player Header Title & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.equalizer, color: AppColors.gold, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            AppStrings.playerHeader,
                            style: TextStyle(
                              fontFamily: 'sans-serif',
                              fontWeight: FontWeight.bold,
                              fontSize: isCompact ? 11 : 12,
                              letterSpacing: 1.5,
                              color: AppColors.gold.withValues(alpha: 0.9),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: audioState.isPlaying
                          ? AppColors.gold.withValues(alpha: 0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: audioState.isPlaying ? AppColors.gold : Colors.white24,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: audioState.isPlaying
                                ? AppColors.gold
                                : (audioState.isLoading ? Colors.orange : Colors.grey),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          audioState.isLoading
                              ? 'CHARGEMENT...'
                              : (audioState.isPlaying ? 'EN LECTURE' : 'EN PAUSE'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: audioState.isPlaying ? AppColors.gold : Colors.white60,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Active Track Display & Equalizer Visualizer
              Row(
                children: [
                  Container(
                    height: isCompact ? 60 : 72,
                    width: isCompact ? 60 : 72,
                    decoration: BoxDecoration(
                      color: AppColors.cardDarkSlate,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (audioState.isPlaying)
                            SizedBox(
                              width: isCompact ? 42 : 52,
                              height: isCompact ? 42 : 52,
                              child: const CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                              ),
                            ),
                          Icon(
                            audioState.isPlaying ? Icons.graphic_eq : Icons.music_note,
                            color: AppColors.gold,
                            size: isCompact ? 26 : 32,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              activeTrack.genre,
                              style: TextStyle(
                                fontFamily: 'sans-serif',
                                color: AppColors.gold.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (audioState.isRepeat) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'RÉPÉTITION',
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
              ),
              const SizedBox(height: 16),

              // Playback Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.gold,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: AppColors.gold,
                  trackHeight: 4.0,
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

              // Timeline Timers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      audioNotifier.formatDuration(audioState.position),
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                    Text(
                      audioState.duration.inSeconds > 0
                          ? audioNotifier.formatDuration(audioState.duration)
                          : activeTrack.duration,
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Playback Controls Row (100% Responsive Layout)
              _buildResponsiveControls(context, audioState, audioNotifier, isCompact),

              const SizedBox(height: 20),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 16),

              // Genre Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: genres.map((genre) {
                    final isSelected = audioState.selectedGenre == genre;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(genre),
                        selected: isSelected,
                        selectedColor: AppColors.gold,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        labelStyle: TextStyle(
                          fontFamily: 'sans-serif',
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.navy : Colors.white70,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.gold : Colors.white24,
                          ),
                        ),
                        onSelected: (_) => audioNotifier.filterByGenre(genre),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Search Field
              TextField(
                onChanged: (val) => audioNotifier.setSearchQuery(val),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Rechercher une chanson...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Playlist Items
              filteredTracks.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'Aucun morceau trouvé',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
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
                        final originalIndex = audioState.tracks.indexOf(track);
                        final isCurrent = originalIndex == audioState.activeTrackIndex;

                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            dense: true,
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppColors.gold.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCurrent && audioState.isPlaying
                                  ? Icons.volume_up
                                  : Icons.play_arrow_outlined,
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
                            ),
                          ),
                          trailing: Text(
                            isCurrent && audioState.duration.inSeconds > 0
                                ? audioNotifier.formatDuration(audioState.duration)
                                : track.duration,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          onTap: () => audioNotifier.selectTrack(originalIndex),
                        ),
                      );
                    },
                    ),
            ],
          ),
        );
      },
    );
  }

  /// Builds fully responsive playback controls with no hardcoded width overflow risks
  Widget _buildResponsiveControls(
    BuildContext context,
    AudioState audioState,
    AudioNotifier audioNotifier,
    bool isCompact,
  ) {
    if (isCompact) {
      // Mobile / Compact Layout: 2 Rows to prevent horizontal overflow
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.repeat,
                  color: audioState.isRepeat ? AppColors.gold : Colors.white38,
                  size: 22,
                ),
                onPressed: () => audioNotifier.toggleRepeat(),
                tooltip: 'Répétition',
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 28),
                onPressed: () => audioNotifier.prevTrack(),
                tooltip: 'Précédent',
              ),
              GestureDetector(
                onTap: () => audioNotifier.togglePlayPause(),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: audioState.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.navy),
                          ),
                        )
                      : Icon(
                          audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: AppColors.navy,
                          size: 28,
                        ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
                onPressed: () => audioNotifier.nextTrack(),
                tooltip: 'Suivant',
              ),
              IconButton(
                icon: Icon(
                  audioState.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: AppColors.gold,
                  size: 22,
                ),
                onPressed: () => audioNotifier.toggleMute(),
                tooltip: 'Sourdine',
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
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppColors.gold,
                    trackHeight: 2.5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.0),
                  ),
                  child: Slider(
                    value: audioState.isMuted ? 0.0 : audioState.volume,
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

    // Tablet & Desktop Layout: Single Balanced Row with flexible Volume control
    return Row(
      children: [
        // Volume Control Block (Flexible width, no fixed overflow)
        IconButton(
          icon: Icon(
            audioState.isMuted
                ? Icons.volume_off
                : (audioState.volume < 0.5 ? Icons.volume_down : Icons.volume_up),
            color: AppColors.gold,
            size: 20,
          ),
          onPressed: () => audioNotifier.toggleMute(),
          tooltip: 'Sourdine',
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 80),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.gold,
              inactiveTrackColor: Colors.white24,
              thumbColor: AppColors.gold,
              trackHeight: 2.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4.0),
            ),
            child: Slider(
              value: audioState.isMuted ? 0.0 : audioState.volume,
              min: 0.0,
              max: 1.0,
              onChanged: (vol) => audioNotifier.setVolume(vol),
            ),
          ),
        ),

        const Spacer(),

        // Main Controls
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 28),
          onPressed: () => audioNotifier.prevTrack(),
          tooltip: 'Précédent',
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => audioNotifier.togglePlayPause(),
          child: Container(
            height: 52,
            width: 52,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: audioState.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(14.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.navy),
                    ),
                  )
                : Icon(
                    audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppColors.navy,
                    size: 30,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
          onPressed: () => audioNotifier.nextTrack(),
          tooltip: 'Suivant',
        ),

        const Spacer(),

        // Extra Options (Repeat Mode Toggle)
        IconButton(
          icon: Icon(
            Icons.repeat,
            color: audioState.isRepeat ? AppColors.gold : Colors.white38,
            size: 22,
          ),
          onPressed: () => audioNotifier.toggleRepeat(),
          tooltip: 'Mode Répétition',
        ),
      ],
    );
  }
}


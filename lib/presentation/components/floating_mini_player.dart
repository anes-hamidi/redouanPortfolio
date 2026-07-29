import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/audio_provider.dart';

/// Floating Glassmorphic Audio Mini-Player Bar
class FloatingMiniPlayer extends ConsumerWidget {
  final VoidCallback onTapExpand;

  const FloatingMiniPlayer({
    super.key,
    required this.onTapExpand,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final audioNotifier = ref.read(audioProvider.notifier);
    final track = audioState.activeTrack;

    final progressRatio = (audioState.duration.inMilliseconds > 0)
        ? (audioState.position.inMilliseconds / audioState.duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: onTapExpand,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 650),
        decoration: BoxDecoration(
          color: AppColors.navy.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Progress indicator bar
              LinearProgressIndicator(
                value: progressRatio,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                minHeight: 2.5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Music Icon / Equalizer Indicator
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 1),
                      ),
                      child: Icon(
                        audioState.isPlaying ? Icons.equalizer : Icons.music_note,
                        color: AppColors.gold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Track Title & Artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            track.title,
                            style: const TextStyle(
                              fontFamily: 'serif',
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${track.genre} • ${audioNotifier.formatDuration(audioState.position)} / ${track.duration}',
                            style: TextStyle(
                              fontFamily: 'sans-serif',
                              color: AppColors.gold.withValues(alpha: 0.85),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Mute Toggle
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: Icon(
                        audioState.isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white70,
                        size: 18,
                      ),
                      onPressed: () => audioNotifier.toggleMute(),
                      tooltip: 'Muet',
                    ),

                    // Play/Pause Button
                    InkWell(
                      onTap: () => audioNotifier.togglePlayPause(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: audioState.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.navy),
                                ),
                              )
                            : Icon(
                                audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: AppColors.navy,
                                size: 20,
                              ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Next Track Button
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: const Icon(Icons.skip_next, color: Colors.white70, size: 20),
                      onPressed: () => audioNotifier.nextTrack(),
                      tooltip: 'Piste suivante',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

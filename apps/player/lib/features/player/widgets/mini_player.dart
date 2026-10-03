import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/audio/audio_player_provider.dart';
import '../../../providers/playlists/favorites_provider.dart';
import '../../../providers/playback/current_song_provider.dart';
import '../../../providers/playback/playback_controller_provider.dart';
import '../../../providers/playback/playback_mode_provider.dart';
import '../../../providers/playback/playback_provider.dart';
import '../../../providers/settings_provider.dart';
import '../player_page.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);
    if (song == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final audio = ref.read(audioPlayerProvider);
    final controller = ref.read(playbackControllerProvider);
    final isPlaying = ref.watch(playingProvider).value ?? audio.isPlaying;
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final duration = ref.watch(durationProvider).value ?? song.duration;
    final shuffle = ref.watch(shuffleProvider);
    final repeatMode = ref.watch(repeatModeProvider);
    final isFavorite = ref.watch(favoritesProvider).contains(song.path);
    final appSettings = ref.watch(settingsProvider);
    final glass = appSettings.liquidGlass;
    final compact = MediaQuery.sizeOf(context).width < 780;
    final progress = duration.inMilliseconds <= 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 10 : 24, 0, compact ? 10 : 24, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: glass ? 22 : 0,
            sigmaY: glass ? 22 : 0,
          ),
          child: Container(
            height: compact ? 82 : 102,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: glass ? .78 : 1),
                  Color.alphaBlend(
                    theme.colorScheme.primary.withValues(alpha: glass ? .08 : .035),
                    theme.colorScheme.surface,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: .09),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .24),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: compact ? 6 : 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PlayerPage()),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'artwork-${song.path}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: SizedBox(
                                    width: compact ? 50 : 66,
                                    height: compact ? 50 : 66,
                                    child: song.artwork != null
                                        ? Image.memory(song.artwork!, fit: BoxFit.cover)
                                        : ColoredBox(
                                            color: theme
                                                .colorScheme
                                                .primaryContainer,
                                            child: Icon(
                                              Icons.album_rounded,
                                              color: theme.colorScheme.primary,
                                              size: 28,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(width: compact ? 10 : 15),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      song.artist.isEmpty
                                          ? 'Unknown Artist'
                                          : song.artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!compact)
                                IconButton(
                                  tooltip: isFavorite ? 'Remove from liked songs' : 'Add to liked songs',
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(
                                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    size: 20,
                                    color: isFavorite
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () => ref.read(favoritesProvider.notifier).toggle(song.path),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: compact ? 4 : 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: 'Previous track',
                            visualDensity: compact
                                ? VisualDensity.compact
                                : VisualDensity.standard,
                            onPressed: () => controller.previous(),
                            icon: const Icon(Icons.skip_previous_rounded),
                          ),
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: const CircleBorder(),
                                elevation: 5,
                                shadowColor: theme.colorScheme.primary.withValues(alpha: .42),
                              ),
                              onPressed: audio.togglePlayPause,
                              child: Icon(
                                isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 25,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Next track',
                            visualDensity: compact
                                ? VisualDensity.compact
                                : VisualDensity.standard,
                            onPressed: () => controller.next(),
                            icon: const Icon(Icons.skip_next_rounded),
                          ),
                        ],
                      ),
                    ),
                    if (!compact)
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (appSettings.miniPlayerShowShuffle)
                              IconButton(
                              tooltip: shuffle ? 'Turn shuffle off' : 'Turn shuffle on',
                              icon: Icon(
                                Icons.shuffle_rounded,
                                color: shuffle ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () => ref.read(shuffleProvider.notifier).toggle(),
                            ),
                            if (appSettings.miniPlayerShowRepeat)
                              IconButton(
                              tooltip: repeatMode == PlaybackRepeatMode.off
                                  ? 'Repeat off'
                                  : repeatMode == PlaybackRepeatMode.one
                                  ? 'Repeat one'
                                  : 'Repeat all',
                              icon: Icon(
                                repeatMode == PlaybackRepeatMode.one
                                    ? Icons.repeat_one_rounded
                                    : Icons.repeat_rounded,
                                size: 20,
                                color: repeatMode == PlaybackRepeatMode.off
                                    ? theme.colorScheme.onSurfaceVariant
                                    : theme.colorScheme.primary,
                              ),
                              onPressed: () => ref
                                  .read(repeatModeProvider.notifier)
                                  .nextMode(),
                            ),
                            if (appSettings.miniPlayerShowQueue)
                              IconButton(
                              tooltip: 'Open queue',
                              onPressed: () => context.push('/queue'),
                              icon: const Icon(Icons.queue_music_rounded),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: -20,
                  height: 48,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 4,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: progress,
                      min: 0,
                      max: 1,
                      onChanged: duration.inMilliseconds <= 0 ? null : (_) {},
                      onChangeEnd: duration.inMilliseconds <= 0
                          ? null
                          : (value) => audio.seek(
                              Duration(
                                milliseconds: (duration.inMilliseconds * value)
                                    .round(),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
import '../../../services/audio_player_service.dart';
import '../player_page.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);
    if (song == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 520;
    final audio = ref.read(audioPlayerProvider);
    final settings = ref.watch(settingsProvider);
    final isPlaying = ref.watch(playingProvider).value ?? audio.isPlaying;
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final duration = ref.watch(durationProvider).value ?? song.duration;
    final shuffle = ref.watch(shuffleProvider);
    final repeat = ref.watch(repeatModeProvider);
    final favorite = ref.watch(favoritesProvider).contains(song.path);
    final progress = duration.inMilliseconds <= 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    void openPlayer() =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => const PlayerPage()));

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: openPlayer,
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: settings.liquidGlass ? settings.glassBlurSigma : 0,
                    sigmaY: settings.liquidGlass ? settings.glassBlurSigma : 0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: settings.gradientBackground
                          ? null
                          : theme.colorScheme.surface.withValues(
                              alpha: settings.liquidGlass
                                  ? settings.glassSurfaceOpacity
                                  : .97,
                            ),
                      gradient: settings.gradientBackground
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.surface.withValues(
                                  alpha: settings.liquidGlass
                                      ? settings.glassSurfaceOpacity
                                      : .98,
                                ),
                                Color.alphaBlend(
                                  theme.colorScheme.primary.withValues(
                                    alpha: settings.liquidGlass ? .12 : .035,
                                  ),
                                  theme.colorScheme.surface,
                                ),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: settings.liquidGlass ? .16 : .09,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: .20,
                          ),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 64,
                          child: Row(
                            children: [
                              Expanded(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: openPlayer,
                                    borderRadius: BorderRadius.circular(28),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Row(
                                        children: [
                                          Hero(
                                            tag: 'artwork-${song.path}',
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              child: SizedBox.square(
                                                dimension: 46,
                                                child: song.artwork == null
                                                    ? ColoredBox(
                                                        color: theme
                                                            .colorScheme
                                                            .primaryContainer,
                                                        child: Icon(
                                                          Icons.album_rounded,
                                                          color: theme
                                                              .colorScheme
                                                              .onPrimaryContainer,
                                                        ),
                                                      )
                                                    : Image.memory(
                                                        song.artwork!,
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 11),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  song.title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  song.artist.isEmpty
                                                      ? 'Unknown Artist'
                                                      : song.artist,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
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
                                              tooltip: favorite
                                                  ? 'Remove from liked songs'
                                                  : 'Add to liked songs',
                                              onPressed: () => ref
                                                  .read(
                                                    favoritesProvider.notifier,
                                                  )
                                                  .toggle(song.path),
                                              icon: Icon(
                                                favorite
                                                    ? Icons.favorite_rounded
                                                    : Icons
                                                          .favorite_border_rounded,
                                                size: 19,
                                                color: favorite
                                                    ? theme.colorScheme.primary
                                                    : theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _ControlIcon(
                                tooltip: 'Previous track',
                                icon: Icons.skip_previous_rounded,
                                onPressed: () => ref
                                    .read(playbackControllerProvider)
                                    .previous(),
                              ),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: const CircleBorder(),
                                  ),
                                  onPressed: audio.togglePlayPause,
                                  child: Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 23,
                                  ),
                                ),
                              ),
                              _ControlIcon(
                                tooltip: 'Next track',
                                icon: Icons.skip_next_rounded,
                                onPressed: () =>
                                    ref.read(playbackControllerProvider).next(),
                              ),
                              const SizedBox(width: 4),
                              if (settings.miniPlayerShowQueue)
                                _ControlIcon(
                                  tooltip: 'Open queue',
                                  icon: Icons.queue_music_rounded,
                                  onPressed: () => context.push('/queue'),
                                ),
                              _ControlIcon(
                                tooltip: 'Open Now Playing with lyrics',
                                icon: Icons.lyrics_rounded,
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const PlayerPage(
                                      showLyricsInitially: true,
                                    ),
                                  ),
                                ),
                              ),
                              if (!compact)
                                PopupMenuButton<_MiniPlayerAction>(
                                  tooltip: 'More player controls',
                                  onSelected: (action) {
                                    switch (action) {
                                      case _MiniPlayerAction.shuffle:
                                        ref
                                            .read(shuffleProvider.notifier)
                                            .toggle();
                                        break;
                                      case _MiniPlayerAction.repeat:
                                        ref
                                            .read(repeatModeProvider.notifier)
                                            .nextMode();
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    if (settings.miniPlayerShowShuffle)
                                      PopupMenuItem(
                                        value: _MiniPlayerAction.shuffle,
                                        child: Text(
                                          shuffle
                                              ? 'Shuffle on'
                                              : 'Shuffle off',
                                        ),
                                      ),
                                    if (settings.miniPlayerShowRepeat)
                                      PopupMenuItem(
                                        value: _MiniPlayerAction.repeat,
                                        child: Text(switch (repeat) {
                                          PlaybackRepeatMode.off =>
                                            'Repeat off',
                                          PlaybackRepeatMode.one =>
                                            'Repeat one',
                                          PlaybackRepeatMode.all =>
                                            'Repeat all',
                                        }),
                                      ),
                                  ],
                                  icon: const Icon(Icons.more_horiz_rounded),
                                ),
                              _ControlIcon(
                                tooltip: 'Volume',
                                icon: Icons.volume_up_rounded,
                                onPressed: () => _showVolume(context, audio),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 14,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 2.5,
                              ),
                              overlayShape: SliderComponentShape.noOverlay,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                            ),
                            child: Slider(
                              value: progress,
                              min: 0,
                              max: 1,
                              onChanged: duration.inMilliseconds <= 0
                                  ? null
                                  : (value) => audio.seek(
                                      Duration(
                                        milliseconds:
                                            (duration.inMilliseconds * value)
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
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _showVolume(
    BuildContext context,
    AudioPlayerService audio,
  ) async {
    var volume = audio.volume;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              children: [
                const Icon(Icons.volume_down_rounded),
                Expanded(
                  child: Slider(
                    value: volume.clamp(0, 100),
                    max: 100,
                    onChanged: (value) {
                      setState(() => volume = value);
                      audio.setVolume(value);
                    },
                  ),
                ),
                const Icon(Icons.volume_up_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlIcon extends StatelessWidget {
  const _ControlIcon({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    visualDensity: VisualDensity.compact,
    onPressed: onPressed,
    icon: Icon(icon),
  );
}

enum _MiniPlayerAction { shuffle, repeat }

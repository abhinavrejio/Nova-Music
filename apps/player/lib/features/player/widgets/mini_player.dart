import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/audio/audio_player_provider.dart';
import '../../../providers/playback/current_song_provider.dart';
import '../../../providers/playback/playback_controller_provider.dart';
import '../../../providers/playback/playback_mode_provider.dart';
import '../../../providers/playback/playback_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/audio_player_service.dart';
import '../player_page.dart';
import '../../../services/keyboard_shortcut_service.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);
    if (song == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 520;
    final desktop = width >= 800;
    final audio = ref.read(audioPlayerProvider);
    final settings = ref.watch(settingsProvider);
    final isPlaying = ref.watch(playingProvider).value ?? audio.isPlaying;
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final duration = ref.watch(durationProvider).value ?? song.duration;
    final shuffle = ref.watch(shuffleProvider);
    final repeat = ref.watch(repeatModeProvider);
    final progress = duration.inMilliseconds <= 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    void openPlayer() =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => const PlayerPage()));

    Widget trackInfo({required double artworkSize}) => Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: openPlayer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox.square(
                  dimension: artworkSize,
                  child: song.artwork == null
                      ? ColoredBox(
                          color: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.album_rounded,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        )
                      : Image.memory(song.artwork!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      song.artist.isEmpty ? 'Unknown Artist' : song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Widget playButton({double size = 42}) => Tooltip(
      message:
          'Play or pause (${KeyboardShortcutService.display(settings.playPauseShortcut)})',
      child: SizedBox(
        width: size,
        height: size,
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: const CircleBorder(),
          ),
          onPressed: () => audio.togglePlayPauseFor(song.path),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: size * .58,
          ),
        ),
      ),
    );

    Widget seekbar({required bool showTimes}) => Row(
      children: [
        if (showTimes)
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              _formatDuration(position),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: showTimes ? 5 : 2.5,
              ),
              overlayShape: SliderComponentShape.noOverlay,
              padding: EdgeInsets.symmetric(horizontal: showTimes ? 10 : 8),
            ),
            child: Slider(
              value: progress,
              min: 0,
              max: 1,
              onChanged: duration.inMilliseconds <= 0
                  ? null
                  : (value) => audio.seek(
                      Duration(
                        milliseconds: (duration.inMilliseconds * value).round(),
                      ),
                    ),
            ),
          ),
        ),
        if (showTimes)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              _formatDuration(duration),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );

    final playerBar = desktop
        ? SizedBox(
            height: 78,
            child: Row(
              children: [
                SizedBox(
                  width: (width * .23).clamp(190, 320),
                  child: trackInfo(artworkSize: 48),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (settings.miniPlayerShowShuffle)
                              _ControlIcon(
                                tooltip: shuffle ? 'Shuffle on' : 'Shuffle off',
                                icon: Icons.shuffle_rounded,
                                active: shuffle,
                                onPressed: () =>
                                    ref.read(shuffleProvider.notifier).toggle(),
                              ),
                            _ControlIcon(
                              tooltip:
                                  'Previous (${KeyboardShortcutService.display(settings.previousTrackShortcut)})',
                              icon: Icons.skip_previous_rounded,
                              onPressed: () => ref
                                  .read(playbackControllerProvider)
                                  .previous(),
                            ),
                            playButton(size: 40),
                            _ControlIcon(
                              tooltip:
                                  'Next (${KeyboardShortcutService.display(settings.nextTrackShortcut)})',
                              icon: Icons.skip_next_rounded,
                              onPressed: () =>
                                  ref.read(playbackControllerProvider).next(),
                            ),
                            if (settings.miniPlayerShowRepeat)
                              _ControlIcon(
                                tooltip: switch (repeat) {
                                  PlaybackRepeatMode.off => 'Repeat off',
                                  PlaybackRepeatMode.one => 'Repeat one',
                                  PlaybackRepeatMode.all => 'Repeat all',
                                },
                                icon: repeat == PlaybackRepeatMode.one
                                    ? Icons.repeat_one_rounded
                                    : Icons.repeat_rounded,
                                active: repeat != PlaybackRepeatMode.off,
                                onPressed: () => ref
                                    .read(repeatModeProvider.notifier)
                                    .nextMode(),
                              ),
                          ],
                        ),
                        SizedBox(height: 18, child: seekbar(showTimes: true)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: (width * .23).clamp(190, 320),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (settings.miniPlayerShowQueue)
                        _ControlIcon(
                          tooltip: 'Open queue',
                          icon: Icons.queue_music_rounded,
                          onPressed: () => context.push('/queue'),
                        ),
                      _ControlIcon(
                        tooltip: 'Open Now Playing and lyrics',
                        icon: Icons.lyrics_rounded,
                        onPressed: openPlayer,
                      ),
                      if (!compact)
                        _ControlIcon(
                          tooltip: 'Audio output: system default',
                          icon: Icons.speaker_rounded,
                          onPressed: () => _showOutputInfo(context),
                        ),
                      _ControlIcon(
                        tooltip: 'Volume',
                        icon: Icons.volume_up_rounded,
                        onPressed: () => _showVolume(context, audio),
                      ),
                      if (width >= 1100)
                        _ControlIcon(
                          tooltip: 'Open full player',
                          icon: Icons.open_in_full_rounded,
                          onPressed: openPlayer,
                        ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    Expanded(child: trackInfo(artworkSize: 46)),
                    _ControlIcon(
                      tooltip: 'Previous track',
                      icon: Icons.skip_previous_rounded,
                      onPressed: () =>
                          ref.read(playbackControllerProvider).previous(),
                    ),
                    playButton(),
                    _ControlIcon(
                      tooltip: 'Next track',
                      icon: Icons.skip_next_rounded,
                      onPressed: () =>
                          ref.read(playbackControllerProvider).next(),
                    ),
                    if (settings.miniPlayerShowQueue)
                      _ControlIcon(
                        tooltip: 'Open queue',
                        icon: Icons.queue_music_rounded,
                        onPressed: () => context.push('/queue'),
                      ),
                    _ControlIcon(
                      tooltip: 'Open Now Playing with lyrics',
                      icon: Icons.lyrics_rounded,
                      onPressed: openPlayer,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              SizedBox(height: 14, child: seekbar(showTimes: false)),
            ],
          );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: desktop
            ? EdgeInsets.zero
            : const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: desktop ? width : 850),
          child: SizedBox(
            width: desktop ? width : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(desktop ? 0 : 14),
              child: Material(
                color: Colors.transparent,
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
                      borderRadius: BorderRadius.circular(desktop ? 0 : 14),
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
                    child: playerBar,
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

  static void _showOutputInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.speaker_rounded),
        title: const Text('Audio output'),
        content: const Text(
          'Nova is using your system default audio device. Choose a different output in your device’s sound settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class _ControlIcon extends StatelessWidget {
  const _ControlIcon({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.active = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    visualDensity: VisualDensity.compact,
    onPressed: onPressed,
    icon: Icon(
      icon,
      color: active ? Theme.of(context).colorScheme.primary : null,
    ),
  );
}

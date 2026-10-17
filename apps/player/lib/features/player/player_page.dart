import 'dart:async';
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../providers/audio/audio_player_provider.dart';
import '../../models/app_settings.dart';
import '../../providers/playback/current_song_provider.dart';
import '../../providers/playback/album_artwork_color_provider.dart';
import '../../providers/playback/playback_controller_provider.dart';
import '../../providers/playback/playback_mode_provider.dart';
import '../../providers/playback/playback_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/playlists/favorites_provider.dart';
import '../lyrics/widgets/lyrics_now_playing_panel.dart';
import '../lyrics/lyrics_page.dart';
import '../../services/keyboard_shortcut_service.dart';
import 'player_widgets.dart';
import 'widgets/player_backdrop.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key, this.showLyricsInitially = true});

  final bool showLyricsInitially;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  static const _windowChannel = MethodChannel('nova/window');
  bool _fullscreen = false;
  late bool _showLyrics;

  @override
  void initState() {
    super.initState();
    _showLyrics = widget.showLyricsInitially;
  }

  Future<void> _toggleFullscreen() async {
    final next = !_fullscreen;
    try {
      await _windowChannel.invokeMethod<void>('setFullscreen', next);
      if (mounted) setState(() => _fullscreen = next);
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not change window display mode.')),
      );
    }
  }

  void _showKeyboardShortcuts() {
    final settings = ref.read(settingsProvider);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard shortcuts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ShortcutRow(
              keys: KeyboardShortcutService.display(settings.playPauseShortcut),
              action: 'Play or pause',
            ),
            _ShortcutRow(
              keys:
                  '${KeyboardShortcutService.display(settings.seekBackwardShortcut)} / ${KeyboardShortcutService.display(settings.seekForwardShortcut)}',
              action: 'Seek 5 seconds',
            ),
            _ShortcutRow(
              keys: KeyboardShortcutService.display(
                settings.previousTrackShortcut,
              ),
              action: 'Previous track',
            ),
            _ShortcutRow(
              keys: KeyboardShortcutService.display(settings.nextTrackShortcut),
              action: 'Next track',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_fullscreen) {
      unawaited(_windowChannel.invokeMethod<void>('setFullscreen', false));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(currentSongProvider);
    if (song == null) {
      return Scaffold(body: const Center(child: Text('No song selected')));
    }

    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);
    final playing = ref.watch(playingProvider);
    final isPlaying = playing.value ?? ref.read(audioPlayerProvider).isPlaying;
    final shuffle = ref.watch(shuffleProvider);
    final repeatMode = ref.watch(repeatModeProvider);
    final settings = ref.watch(settingsProvider);
    final artworkGradient =
        ref.watch(albumArtworkColorProvider(song.path)).value ??
        const Color(0xFFDF6B3E);
    final animationsEnabled =
        settings.animationsEnabled && !MediaQuery.of(context).disableAnimations;
    final totalDuration = duration.value ?? song.duration;
    final elapsed = position.value ?? Duration.zero;

    final favorite = ref.watch(favoritesProvider).contains(song.path);
    final colors = Theme.of(context).colorScheme;
    final panel = colors.surface.withValues(alpha: .88);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final artwork = Hero(
      tag: 'artwork-${song.path}',
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: song.artwork == null
              ? ColoredBox(
                  color: colors.surfaceContainerHighest,
                  child: const Icon(Icons.album_rounded, size: 90),
                )
              : Image.memory(song.artwork!, fit: BoxFit.cover),
        ),
      ),
    );
    final playerCard = Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: panel,
        border: Border.all(color: colors.onSurface.withValues(alpha: .12)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'NOW PLAYING',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: colors.primary, letterSpacing: 1.4),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  song.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: .98,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              IconButton(
                tooltip: favorite
                    ? 'Remove from liked songs'
                    : 'Add to liked songs',
                onPressed: () =>
                    ref.read(favoritesProvider.notifier).toggle(song.path),
                icon: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                  color: favorite ? colors.primary : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${song.artist.isEmpty ? 'Unknown Artist' : song.artist}${song.album.isEmpty ? '' : ' · ${song.album}'}',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          ProgressBar(
            progress: elapsed,
            total: totalDuration,
            barHeight: 4,
            thumbRadius: 7,
            timeLabelPadding: 8,
            timeLabelTextStyle: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: colors.onSurfaceVariant),
            onSeek: (value) => ref.read(audioPlayerProvider).seek(value),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PlayerControl(
                tooltip: shuffle ? 'Turn shuffle off' : 'Turn shuffle on',
                icon: Icons.shuffle_rounded,
                active: shuffle,
                onPressed: () => ref.read(shuffleProvider.notifier).toggle(),
              ),
              _PlayerControl(
                tooltip: 'Previous track',
                icon: Icons.skip_previous_rounded,
                size: 30,
                onPressed: () =>
                    ref.read(playbackControllerProvider).previous(),
              ),
              SizedBox(
                width: 64,
                height: 64,
                child: FloatingActionButton(
                  heroTag: 'now-playing-toggle',
                  tooltip:
                      'Play or pause (${KeyboardShortcutService.display(settings.playPauseShortcut)})',
                  onPressed: () => ref
                      .read(audioPlayerProvider)
                      .togglePlayPauseFor(song.path),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 34,
                  ),
                ),
              ),
              _PlayerControl(
                tooltip: 'Next track',
                icon: Icons.skip_next_rounded,
                size: 30,
                onPressed: () => ref.read(playbackControllerProvider).next(),
              ),
              _PlayerControl(
                tooltip: repeatMode == PlaybackRepeatMode.off
                    ? 'Repeat off'
                    : repeatMode == PlaybackRepeatMode.one
                    ? 'Repeat one'
                    : 'Repeat all',
                icon: repeatMode == PlaybackRepeatMode.one
                    ? Icons.repeat_one_rounded
                    : Icons.repeat_rounded,
                active: repeatMode != PlaybackRepeatMode.off,
                onPressed: () =>
                    ref.read(repeatModeProvider.notifier).nextMode(),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Text(
                'LIVE LYRICS',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: colors.primary, letterSpacing: 1.2),
              ),
              const Spacer(),
              _FloatingIconButton(
                tooltip: _showLyrics ? 'Hide lyrics' : 'Show lyrics',
                icon: _showLyrics
                    ? Icons.lyrics_rounded
                    : Icons.lyrics_outlined,
                active: _showLyrics,
                onPressed: () => setState(() => _showLyrics = !_showLyrics),
              ),
              _FloatingIconButton(
                tooltip: 'Open full-screen lyrics',
                icon: Icons.open_in_full_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LyricsPage(
                      title: song.title,
                      artist: song.artist,
                      trackId: song.path,
                      artwork: song.artwork,
                      album: song.album,
                      duration: totalDuration,
                    ),
                  ),
                ),
              ),
              if (!kIsWeb && Platform.isWindows)
                _FloatingIconButton(
                  tooltip: _fullscreen ? 'Exit full screen' : 'Full screen',
                  icon: _fullscreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  onPressed: _toggleFullscreen,
                ),
            ],
          ),
          if (_showLyrics)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: LyricsNowPlayingPanel(
                  title: song.title,
                  artist: song.artist,
                  trackId: song.path,
                  album: song.album,
                  duration: totalDuration,
                ),
              ),
            )
          else
            const SizedBox(
              height: 90,
              child: Center(child: Text('Lyrics hidden')),
            ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF100D0B),
      body: Stack(
        children: [
          Positioned.fill(
            child: PlayerBackdrop(
              artwork: song.artwork,
              motionEnabled: animationsEnabled,
              style: settings.amoledBlack
                  ? BackgroundStyle.solidColor
                  : settings.backgroundStyle,
              gradientColor: artworkGradient,
              gradientEnabled: settings.backgroundGradient,
              wallpaperPath: settings.wallpaperPath,
              amoledBlack: settings.amoledBlack,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 62,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _FloatingIconButton(
                          tooltip: 'Back',
                          icon: Icons.close_rounded,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PLAYING FROM LOCAL LIBRARY',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: colors.primary,
                                  letterSpacing: 1.1,
                                ),
                          ),
                          Text(
                            song.album.isEmpty ? 'Your library' : song.album,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'OUTPUTTING TO THIS DEVICE',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenuButton<String>(
                          tooltip: 'More options',
                          onSelected: (value) {
                            if (value == 'queue') {
                              Navigator.of(context).pushNamed('/queue');
                            } else if (value == 'shortcuts') {
                              _showKeyboardShortcuts();
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'queue',
                              child: Text('Open queue'),
                            ),
                            PopupMenuItem(
                              value: 'shortcuts',
                              child: Text('Keyboard shortcuts'),
                            ),
                          ],
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.more_horiz_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) {
                      if (wide) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 11,
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 620,
                                    ),
                                    child: artwork,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 56),
                              Expanded(
                                flex: 10,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 620,
                                  ),
                                  child: playerCard,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 430),
                              child: artwork,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(height: 560, child: playerCard),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _PlayerControls extends StatelessWidget {
  const _PlayerControls({
    required this.songPath,
    required this.title,
    required this.artist,
    required this.album,
    required this.artwork,
    required this.artworkSize,
    required this.elapsed,
    required this.totalDuration,
    required this.isPlaying,
    required this.motionEnabled,
    required this.shuffle,
    required this.repeatMode,
    required this.actions,
    required this.onSeek,
    required this.onTogglePlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.onShuffle,
    required this.onRepeat,
  });

  final String songPath;
  final String title;
  final String artist;
  final String album;
  final Uint8List? artwork;
  final double artworkSize;
  final Duration elapsed;
  final Duration totalDuration;
  final bool isPlaying;
  final bool motionEnabled;
  final bool shuffle;
  final PlaybackRepeatMode repeatMode;
  final Widget actions;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: .96, end: 1),
            duration: motionEnabled
                ? const Duration(milliseconds: 520)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Hero(
              tag: 'artwork-$songPath',
              child: AnimatedContainer(
                duration: motionEnabled
                    ? const Duration(milliseconds: 650)
                    : Duration.zero,
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(
                        alpha: isPlaying ? .24 : 0,
                      ),
                      blurRadius: isPlaying ? 56 : 0,
                      spreadRadius: isPlaying ? 3 : 0,
                    ),
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: .28),
                      blurRadius: 38,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: AlbumArtwork(artwork: artwork, size: artworkSize),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          artist.isEmpty ? 'Unknown Artist' : artist,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (album.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            album,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: .78),
            ),
          ),
        ],
        const SizedBox(height: 18),
        actions,
        const SizedBox(height: 8),
        Column(
          children: [
            ProgressBar(
              progress: elapsed,
              total: totalDuration,
              barHeight: 5,
              thumbRadius: 7,
              timeLabelPadding: 8,
              timeLabelTextStyle: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onSeek: onSeek,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PlayerControl(
                  tooltip: shuffle ? 'Turn shuffle off' : 'Turn shuffle on',
                  icon: Icons.shuffle_rounded,
                  active: shuffle,
                  onPressed: onShuffle,
                ),
                _PlayerControl(
                  tooltip: 'Previous track',
                  icon: Icons.skip_previous_rounded,
                  size: 34,
                  onPressed: onPrevious,
                ),
                SizedBox(
                  width: 64,
                  height: 64,
                  child: FloatingActionButton(
                    heroTag: 'now-playing-toggle',
                    onPressed: onTogglePlayPause,
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 34,
                    ),
                  ),
                ),
                _PlayerControl(
                  tooltip: 'Next track',
                  icon: Icons.skip_next_rounded,
                  size: 34,
                  onPressed: onNext,
                ),
                _PlayerControl(
                  tooltip: switch (repeatMode) {
                    PlaybackRepeatMode.off => 'Repeat off',
                    PlaybackRepeatMode.one => 'Repeat one',
                    PlaybackRepeatMode.all => 'Repeat all',
                  },
                  icon: repeatMode == PlaybackRepeatMode.one
                      ? Icons.repeat_one_rounded
                      : Icons.repeat_rounded,
                  active: repeatMode != PlaybackRepeatMode.off,
                  onPressed: onRepeat,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _FloatingIconButton extends StatelessWidget {
  const _FloatingIconButton({
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: IconButton.filledTonal(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.surface.withValues(alpha: .30),
          foregroundColor: active
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          visualDensity: VisualDensity.compact,
        ),
        icon: Icon(icon),
      ),
    );
  }
}

class _PlayerControl extends StatelessWidget {
  const _PlayerControl({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.active = false,
    this.size = 24,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: size,
      color: active
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurfaceVariant,
      icon: Icon(icon),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.keys, required this.action});

  final String keys;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            child: Text(
              keys,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(action)),
        ],
      ),
    );
  }
}

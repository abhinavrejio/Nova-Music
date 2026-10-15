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
import '../lyrics/widgets/lyrics_now_playing_panel.dart';
import '../../shared/widgets/glass_surface.dart';
import 'player_widgets.dart';
import 'widgets/player_backdrop.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key, this.showLyricsInitially = false});

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
        const Color(0xFFFF6B5F);
    final animationsEnabled = settings.animationsEnabled;
    final totalDuration = duration.value ?? song.duration;
    final elapsed = position.value ?? Duration.zero;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
          Positioned.fill(
            child: SafeArea(
              child: Stack(
                children: [
                  if (!_fullscreen)
                    Positioned(
                      top: 4,
                      left: 6,
                      child: _FloatingIconButton(
                        tooltip: 'Back',
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 960;
                        final artworkSize = wide && !_showLyrics
                            ? (constraints.maxHeight * .59).clamp(340.0, 640.0)
                            : wide
                            ? (constraints.maxWidth * .34).clamp(240.0, 360.0)
                            : ((constraints.maxWidth - 44) * .82).clamp(
                                220.0,
                                360.0,
                              );

                        final controls = _PlayerControls(
                          songPath: song.path,
                          title: song.title,
                          artist: song.artist,
                          album: song.album,
                          artwork: song.artwork,
                          artworkSize: artworkSize,
                          elapsed: elapsed,
                          totalDuration: totalDuration,
                          isPlaying: isPlaying,
                          shuffle: shuffle,
                          repeatMode: repeatMode,
                          actions: Row(
                            children: [
                              const Spacer(),
                              _FloatingIconButton(
                                tooltip: _showLyrics
                                    ? 'Hide lyrics'
                                    : 'Show lyrics',
                                icon: _showLyrics
                                    ? Icons.lyrics_rounded
                                    : Icons.lyrics_outlined,
                                active: _showLyrics,
                                onPressed: () =>
                                    setState(() => _showLyrics = !_showLyrics),
                              ),
                              if (!kIsWeb && Platform.isWindows)
                                _FloatingIconButton(
                                  tooltip: _fullscreen
                                      ? 'Exit full screen'
                                      : 'Full screen',
                                  icon: _fullscreen
                                      ? Icons.fullscreen_exit_rounded
                                      : Icons.fullscreen_rounded,
                                  onPressed: _toggleFullscreen,
                                ),
                            ],
                          ),
                          onSeek: (value) =>
                              ref.read(audioPlayerProvider).seek(value),
                          onTogglePlayPause: () =>
                              ref.read(audioPlayerProvider).togglePlayPause(),
                          onPrevious: () =>
                              ref.read(playbackControllerProvider).previous(),
                          onNext: () =>
                              ref.read(playbackControllerProvider).next(),
                          onShuffle: () =>
                              ref.read(shuffleProvider.notifier).toggle(),
                          onRepeat: () =>
                              ref.read(repeatModeProvider.notifier).nextMode(),
                        );

                        final topInset = wide ? 20.0 : 58.0;
                        final bottomInset = wide ? 20.0 : 30.0;
                        final controlsPane = SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            wide ? 20 : 22,
                            topInset,
                            wide ? 20 : 22,
                            bottomInset,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  (constraints.maxHeight -
                                          topInset -
                                          bottomInset)
                                      .clamp(0.0, double.infinity),
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: wide && _showLyrics ? 760 : 900,
                                ),
                                child: settings.liquidGlass
                                    ? GlassSurface(
                                        blur: settings.glassBlurSigma,
                                        surfaceOpacity:
                                            settings.glassSurfaceOpacity,
                                        borderRadius: BorderRadius.circular(30),
                                        padding: const EdgeInsets.fromLTRB(
                                          14,
                                          10,
                                          14,
                                          4,
                                        ),
                                        child: controls,
                                      )
                                    : controls,
                              ),
                            ),
                          ),
                        );

                        if (wide && _showLyrics) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1480,
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(flex: 5, child: controlsPane),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      flex: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 54),
                                        child: settings.liquidGlass
                                            ? GlassSurface(
                                                blur: settings.glassBlurSigma,
                                                surfaceOpacity: settings
                                                    .glassSurfaceOpacity,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: LyricsNowPlayingPanel(
                                                  title: song.title,
                                                  artist: song.artist,
                                                  trackId: song.path,
                                                  album: song.album,
                                                  duration: totalDuration,
                                                ),
                                              )
                                            : LyricsNowPlayingPanel(
                                                title: song.title,
                                                artist: song.artist,
                                                trackId: song.path,
                                                album: song.album,
                                                duration: totalDuration,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        if (_showLyrics) {
                          return Column(
                            children: [
                              Expanded(child: controlsPane),
                              SizedBox(
                                height: constraints.maxHeight * .48,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    0,
                                    12,
                                    12,
                                  ),
                                  child: settings.liquidGlass
                                      ? GlassSurface(
                                          blur: settings.glassBlurSigma,
                                          surfaceOpacity:
                                              settings.glassSurfaceOpacity,
                                          borderRadius: BorderRadius.circular(
                                            26,
                                          ),
                                          padding: const EdgeInsets.all(8),
                                          child: LyricsNowPlayingPanel(
                                            title: song.title,
                                            artist: song.artist,
                                            trackId: song.path,
                                            album: song.album,
                                            duration: totalDuration,
                                          ),
                                        )
                                      : LyricsNowPlayingPanel(
                                          title: song.title,
                                          artist: song.artist,
                                          trackId: song.path,
                                          album: song.album,
                                          duration: totalDuration,
                                        ),
                                ),
                              ),
                            ],
                          );
                        }

                        return controlsPane;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: .96, end: 1),
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Hero(
              tag: 'artwork-$songPath',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
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
        const SizedBox(height: 24),
        const SizedBox(height: 18),
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
                  width: 72,
                  height: 72,
                  child: FloatingActionButton(
                    heroTag: 'now-playing-toggle',
                    onPressed: onTogglePlayPause,
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 36,
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

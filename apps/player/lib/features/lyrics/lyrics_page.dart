import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_settings.dart';
import '../../providers/audio/audio_player_provider.dart';
import '../../providers/playback/playback_provider.dart';
import '../../providers/settings_provider.dart';
import 'lyrics_provider.dart';
import 'widgets/lyrics_scroll_view.dart';
import '../player/widgets/player_backdrop.dart';

class LyricsPage extends ConsumerWidget {
  const LyricsPage({
    super.key,
    required this.title,
    required this.artist,
    this.trackId,
    this.artwork,
    this.album,
    this.duration,
  });

  final String title;
  final String artist;
  final String? trackId;
  final Uint8List? artwork;
  final String? album;
  final Duration? duration;

  LyricsQuery get query => (
    title: title,
    artist: artist,
    trackId: trackId ?? '$artist\u0000$title',
    album: album,
    duration: duration,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final lyrics = ref.watch(lyricsProvider(query));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Lyrics'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: PlayerBackdrop(
              artwork: artwork,
              motionEnabled: settings.animationsEnabled,
              style: settings.amoledBlack
                  ? BackgroundStyle.solidColor
                  : settings.backgroundStyle,
              gradientColor: Color(settings.backgroundColorValue),
              gradientEnabled: settings.backgroundGradient,
              wallpaperPath: settings.wallpaperPath,
              amoledBlack: settings.amoledBlack,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: Column(
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        artist.isEmpty ? 'Unknown Artist' : artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: lyrics.when(
                    loading: () => const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Finding synchronized lyrics…'),
                        ],
                      ),
                    ),
                    error: (error, stackTrace) => _LyricsMessage(
                      icon: Icons.wifi_tethering_error_rounded,
                      title: 'Could not load lyrics',
                      message: 'Check your connection and try again.',
                      actionLabel: 'Retry',
                      onPressed: () => ref.invalidate(lyricsProvider(query)),
                    ),
                    data: (value) {
                      if (value == null || value.lines.isEmpty) {
                        return const _LyricsMessage(
                          icon: Icons.lyrics_outlined,
                          title: 'Synchronized lyrics unavailable',
                          message: 'There are no timed lyrics available for this track yet.',
                        );
                      }

                      final position =
                          ref.watch(positionProvider).value ?? Duration.zero;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Chip(
                              avatar: Icon(
                                value.hasWordSync
                                    ? Icons.auto_awesome_rounded
                                    : Icons.subtitles_rounded,
                              ),
                              label: Text(
                                value.hasWordSync
                                    ? 'Word-by-word sync${value.cached ? ' · Saved offline' : ' · ${value.source}'}'
                                    : 'Line sync only${value.cached ? ' · Saved offline' : ' · ${value.source}'}',
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          Expanded(
                            child: LyricsScrollView(
                              lines: value.lines,
                              position: position,
                              onSeek: (time) =>
                                  ref.read(audioPlayerProvider).seek(time),
                            ),
                          ),
                        ],
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

class _LyricsMessage extends StatelessWidget {
  const _LyricsMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 18),
              FilledButton.tonal(
                onPressed: onPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/audio/audio_player_provider.dart';
import '../../../providers/playback/playback_provider.dart';
import '../lyrics_provider.dart';
import 'lyrics_scroll_view.dart';

class LyricsNowPlayingPanel extends ConsumerWidget {
  const LyricsNowPlayingPanel({
    super.key,
    required this.title,
    required this.artist,
    required this.trackId,
    this.album,
    this.duration,
  });

  final String title;
  final String artist;
  final String trackId;
  final String? album;
  final Duration? duration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final query = (
      title: title,
      artist: artist,
      trackId: trackId,
      album: album,
      duration: duration,
    );
    final lyrics = ref.watch(lyricsProvider(query));

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Spacer(),
              lyrics.whenOrNull(
                    data: (value) => value == null
                        ? null
                        : Text(
                            value.hasWordSync
                                ? 'WORD-BY-WORD · ${value.cached ? 'SAVED OFFLINE' : value.source}'
                                : 'LINE SYNC · ${value.cached ? 'SAVED OFFLINE' : value.source}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              letterSpacing: .6,
                            ),
                          ),
                  ) ??
                  const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: lyrics.when(
              loading: () => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 14),
                    Text('Finding synchronized lyrics…'),
                  ],
                ),
              ),
              error: (error, stackTrace) => _PanelMessage(
                icon: Icons.wifi_tethering_error_rounded,
                text: 'Could not load lyrics. Open Lyrics to retry.',
              ),
              data: (value) {
                if (value == null || value.lines.isEmpty) {
                  return const _PanelMessage(
                    icon: Icons.lyrics_outlined,
                    text: 'Timed lyrics are not available for this track.',
                  );
                }
                final position =
                    ref.watch(positionProvider).value ?? Duration.zero;
                return LyricsScrollView(
                  lines: value.lines,
                  position: position,
                  onSeek: (time) => ref.read(audioPlayerProvider).seek(time),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelMessage extends StatelessWidget {
  const _PanelMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 34, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

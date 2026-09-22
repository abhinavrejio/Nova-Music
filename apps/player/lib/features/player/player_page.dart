import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/audio/audio_player_provider.dart';
import '../../providers/playback/current_song_provider.dart';
import '../../providers/playback/playback_controller_provider.dart';
import '../../providers/playback/playback_mode_provider.dart';
import '../../providers/playback/playback_provider.dart';
import '../../providers/playback/playback_speed_provider.dart';
import '../../providers/playback/sleep_timer_provider.dart';
import '../../providers/playlists/favorites_provider.dart';
import 'player_widgets.dart';
import 'queue_page.dart';
import 'widgets/nova_equalizer.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);

    if (song == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Now Playing'),
        ),
        body: const Center(
          child: Text(
            'No song selected',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(song.path);
    final position = ref.watch(positionProvider);
    final duration = ref.watch(durationProvider);
    final playing = ref.watch(playingProvider);
    final isPlaying = playing.value ?? ref.read(audioPlayerProvider).isPlaying;
    final shuffle = ref.watch(shuffleProvider);
    final repeatMode = ref.watch(repeatModeProvider);
    final playbackSpeed = ref.watch(playbackSpeedProvider);
    final sleepTimer = ref.watch(sleepTimerProvider);

    final totalDuration = duration.value ?? song.duration;
    final elapsed = position.value ?? Duration.zero;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Queue',
            icon: const Icon(Icons.queue_music_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const QueuePage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggle(song.path);
            },
          ),
          PopupMenuButton<double>(
            tooltip: 'Playback speed',
            initialValue: playbackSpeed,
            onSelected: (speed) async {
              ref.read(playbackSpeedProvider.notifier).setSpeed(speed);
              await ref.read(audioPlayerProvider).setRate(speed);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 0.75, child: Text('0.75x')),
              PopupMenuItem(value: 1.0, child: Text('1.0x')),
              PopupMenuItem(value: 1.25, child: Text('1.25x')),
              PopupMenuItem(value: 1.5, child: Text('1.5x')),
              PopupMenuItem(value: 2.0, child: Text('2.0x')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('${playbackSpeed}x'),
            ),
          ),
          PopupMenuButton<Duration?>(
            tooltip: 'Sleep timer',
            onSelected: (duration) {
              ref.read(sleepTimerProvider.notifier).setTimer(duration);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: null,
                child: Text(sleepTimer == null ? 'Sleep timer: Off' : 'Turn off timer'),
              ),
              const PopupMenuItem(value: Duration(minutes: 15), child: Text('15 minutes')),
              const PopupMenuItem(value: Duration(minutes: 30), child: Text('30 minutes')),
              const PopupMenuItem(value: Duration(minutes: 60), child: Text('60 minutes')),
            ],
            child: Icon(
              sleepTimer == null ? Icons.bedtime_outlined : Icons.bedtime,
              color: sleepTimer == null ? null : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            image: song.artwork == null
                ? null
                : DecorationImage(
                    image: MemoryImage(song.artwork!),
                    fit: BoxFit.cover,
                    opacity: 0.10,
                  ),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.86),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.94, end: 1),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutBack,
                        builder: (_, scale, child) => Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                        child: Hero(
                          tag: 'artwork-${song.path}',
                          child: AlbumArtwork(
                            artwork: song.artwork,
                            size: 300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      NovaEqualizer(isPlaying: isPlaying),
                      const SizedBox(height: 24),
                      Text(
                        song.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        song.artist.isEmpty ? 'Unknown Artist' : song.artist,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        song.album.isEmpty ? 'Unknown Album' : song.album,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ProgressBar(
                        progress: elapsed,
                        total: totalDuration,
                        barHeight: 6,
                        thumbRadius: 7,
                        timeLabelPadding: 8,
                        timeLabelTextStyle: Theme.of(context).textTheme.labelMedium,
                        onSeek: (value) {
                          ref.read(audioPlayerProvider).seek(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(elapsed),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Text(
                            _formatDuration(totalDuration),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          IconButton(
                            tooltip: 'Shuffle',
                            icon: Icon(
                              Icons.shuffle,
                              color: shuffle
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              ref.read(shuffleProvider.notifier).toggle();
                            },
                          ),
                          IconButton(
                            tooltip: 'Previous track',
                            icon: const Icon(Icons.skip_previous_rounded),
                            iconSize: 42,
                            onPressed: () async {
                              await ref.read(playbackControllerProvider).previous();
                            },
                          ),
                          SizedBox(
                            width: 84,
                            height: 84,
                            child: FloatingActionButton.large(
                              onPressed: () {
                                ref.read(audioPlayerProvider).togglePlayPause();
                              },
                              child: Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 40,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Next track',
                            icon: const Icon(Icons.skip_next_rounded),
                            iconSize: 42,
                            onPressed: () async {
                              await ref.read(playbackControllerProvider).next();
                            },
                          ),
                          IconButton(
                            tooltip: 'Repeat mode',
                            icon: Icon(
                              repeatMode == PlaybackRepeatMode.off
                                  ? Icons.repeat_rounded
                                  : repeatMode == PlaybackRepeatMode.one
                                      ? Icons.repeat_one_rounded
                                      : Icons.repeat_rounded,
                              color: repeatMode == PlaybackRepeatMode.off
                                  ? Theme.of(context).colorScheme.onSurfaceVariant
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              ref.read(repeatModeProvider.notifier).nextMode();
                            },
                          ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
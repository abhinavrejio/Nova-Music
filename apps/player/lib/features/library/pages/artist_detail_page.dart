import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/current_song.dart';
import '../../../providers/audio/audio_player_provider.dart';
import '../../../providers/playback/current_song_provider.dart';
import '../../../providers/playback/queue_index_provider.dart';
import '../../../providers/playback/queue_provider.dart';
import '../../player/player_page.dart';

class ArtistDetailPage extends ConsumerWidget {
  const ArtistDetailPage({
    super.key,
    required this.artistName,
    required this.songs,
  });

  final String artistName;
  final List<CurrentSong> songs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artistName),
      ),
      body: songs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No songs by this artist yet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final song = songs[index];

                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_rounded),
                  ),
                  title: Text(song.title),
                  subtitle: Text(song.album.isEmpty ? 'Unknown Album' : song.album),
                  trailing: Text(_formatDuration(song.duration)),
                  onTap: () async {
                    ref.read(queueProvider.notifier).setQueue(songs);
                    ref.read(queueIndexProvider.notifier).setIndex(index);
                    ref.read(currentSongProvider.notifier).setSong(song);

                    if (song.path.isNotEmpty) {
                      await ref.read(audioPlayerProvider).openFile(song.path);
                    }

                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PlayerPage(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

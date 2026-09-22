import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/current_song.dart';
import '../../../models/playlist.dart';
import '../../../providers/audio/audio_player_provider.dart';
import '../../../providers/library/library_provider.dart';
import '../../../providers/playback/current_song_provider.dart';
import '../../../providers/playback/queue_index_provider.dart';
import '../../../providers/playback/queue_provider.dart';
import '../../../providers/playlists/playlist_provider.dart';
import '../../player/player_page.dart';

class PlaylistDetailPage extends ConsumerWidget {
  const PlaylistDetailPage({
    super.key,
    required this.playlist,
  });

  final Playlist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final librarySongs = ref.watch(libraryProvider);
    final currentPlaylist = ref.watch(playlistProvider).firstWhere(
      (item) => item.id == playlist.id,
      orElse: () => playlist,
    );
    final songs = librarySongs
        .where((song) => currentPlaylist.songPaths.contains(song.path))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPlaylist.name),
        actions: [
          IconButton(
            tooltip: 'Add songs',
            icon: const Icon(Icons.add_rounded),
            onPressed: librarySongs.isEmpty
                ? null
                : () => _showAddSongsDialog(
                      context,
                      ref,
                      currentPlaylist,
                      librarySongs,
                    ),
          ),
        ],
      ),
      body: songs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No songs in this playlist yet.',
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
                    child: Icon(Icons.music_note_rounded),
                  ),
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    song.artist.isEmpty ? 'Unknown Artist' : song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_formatDuration(song.duration)),
                      IconButton(
                        tooltip: 'Remove from playlist',
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          ref
                              .read(playlistProvider.notifier)
                              .removeSong(currentPlaylist.id, song.path);
                        },
                      ),
                    ],
                  ),
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

  Future<void> _showAddSongsDialog(
    BuildContext context,
    WidgetRef ref,
    Playlist currentPlaylist,
    List<CurrentSong> librarySongs,
  ) async {
    final availableSongs = librarySongs
        .where((song) => !currentPlaylist.songPaths.contains(song.path))
        .toList();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add songs'),
          content: SizedBox(
            width: 420,
            height: 360,
            child: availableSongs.isEmpty
                ? const Center(child: Text('All library songs are already added.'))
                : ListView.builder(
                    itemCount: availableSongs.length,
                    itemBuilder: (_, index) {
                      final song = availableSongs[index];
                      return ListTile(
                        title: Text(song.title),
                        subtitle: Text(song.artist),
                        onTap: () async {
                          await ref
                              .read(playlistProvider.notifier)
                              .addSong(currentPlaylist.id, song.path);
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

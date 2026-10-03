import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/current_song.dart';
import '../../models/playlist.dart';
import '../../providers/audio/audio_player_provider.dart';
import '../../providers/library/library_provider.dart';
import '../../providers/playback/current_song_provider.dart';
import '../../providers/playback/queue_index_provider.dart';
import '../../providers/playback/queue_provider.dart';
import '../../providers/playlists/playlist_provider.dart';
import '../../providers/settings_provider.dart';
import '../player/player_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songs = ref.watch(libraryProvider);
    final playlists = ref.watch(playlistProvider);
    final settings = ref.watch(settingsProvider);
    final query = _searchController.text.trim().toLowerCase();

    final filteredSongs = settings.searchShowSongs ? songs.where((song) {
      if (query.isEmpty) return true;
      final text = [
        song.title,
        song.artist,
        song.album,
      ].join(' ').toLowerCase();
      return text.contains(query);
    }).toList() : <CurrentSong>[];

    final filteredPlaylists = settings.searchShowPlaylists ? playlists.where((playlist) {
      if (query.isEmpty) return true;
      return playlist.name.toLowerCase().contains(query);
    }).toList() : <Playlist>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Browse your library',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search songs, artists, albums',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                ),
                onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 24),
              if (filteredSongs.isNotEmpty) ...[
                Text(
                  'Songs',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...filteredSongs.map(
                  (song) => _SongResultTile(
                    song: song,
                    queue: filteredSongs,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (filteredPlaylists.isNotEmpty) ...[
                Text(
                  'Playlists',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...filteredPlaylists.map(
                  (playlist) => _PlaylistResultTile(playlist: playlist),
                ),
              ],
              if (filteredSongs.isEmpty && filteredPlaylists.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'No matches found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SongResultTile extends ConsumerWidget {
  const _SongResultTile({
    required this.song,
    required this.queue,
  });

  final CurrentSong song;
  final List<CurrentSong> queue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () async {
          final selectedIndex = queue.indexWhere((queuedSong) => queuedSong.path == song.path);
          final queueIndex = selectedIndex >= 0 ? selectedIndex : 0;

          ref.read(queueProvider.notifier).setQueue(queue);
          ref.read(queueIndexProvider.notifier).setIndex(queueIndex);
          ref.read(currentSongProvider.notifier).setSong(song);

          final filePath = song.path;
          if (filePath.isNotEmpty && File(filePath).existsSync()) {
            await ref.read(audioPlayerProvider).openFile(filePath);
          }

          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PlayerPage(),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${song.artist} • ${song.album}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDuration(song.duration),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _PlaylistResultTile extends StatelessWidget {
  const _PlaylistResultTile({required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.queue_music_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${playlist.songCount} songs',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

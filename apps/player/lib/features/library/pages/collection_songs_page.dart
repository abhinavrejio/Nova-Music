import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/current_song.dart';
import '../../../providers/audio/audio_player_provider.dart';
import '../../../providers/playback/current_song_provider.dart';
import '../../../providers/playback/queue_index_provider.dart';
import '../../../providers/playback/queue_provider.dart';
import '../../../providers/playlists/favorites_provider.dart';
import 'collection_actions.dart';
import '../../player/player_page.dart';

enum CollectionSort { recent, title, artist, duration }

class CollectionSongsPage extends ConsumerStatefulWidget {
  const CollectionSongsPage({
    super.key,
    required this.title,
    required this.songs,
    required this.emptyMessage,
  });

  final String title;
  final List<CurrentSong> songs;
  final String emptyMessage;

  @override
  ConsumerState<CollectionSongsPage> createState() => _CollectionSongsPageState();
}

class _CollectionSongsPageState extends ConsumerState<CollectionSongsPage> {
  final _searchController = TextEditingController();
  final _selectedPaths = <String>{};
  CollectionSort _sort = CollectionSort.recent;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CurrentSong> get _visibleSongs {
    final query = _query.trim().toLowerCase();
    final filtered = widget.songs.where((song) {
      if (query.isEmpty) return true;
      return song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query) ||
          song.album.toLowerCase().contains(query);
    }).toList();

    switch (_sort) {
      case CollectionSort.recent:
        return filtered;
      case CollectionSort.title:
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case CollectionSort.artist:
        filtered.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
      case CollectionSort.duration:
        filtered.sort((a, b) => b.duration.compareTo(a.duration));
    }
    return filtered;
  }

  bool get _selecting => _selectedPaths.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final songs = _visibleSongs;
    final selectedSongs = widget.songs.where((song) => _selectedPaths.contains(song.path)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_selecting ? '${_selectedPaths.length} selected' : widget.title),
        actions: [
          if (_selecting) ...[
            IconButton(
              tooltip: 'Add selected to queue',
              icon: const Icon(Icons.queue_music_rounded),
              onPressed: () => _addToQueue(selectedSongs),
            ),
            IconButton(
              tooltip: 'Add selected to playlist',
              icon: const Icon(Icons.playlist_add_rounded),
              onPressed: () => showCollectionPlaylistPicker(context, ref, selectedSongs),
            ),
            IconButton(
              tooltip: 'Clear selection',
              icon: const Icon(Icons.close_rounded),
              onPressed: () => setState(_selectedPaths.clear),
            ),
          ] else ...[
            PopupMenuButton<CollectionSort>(
              tooltip: 'Sort',
              icon: const Icon(Icons.sort_rounded),
              initialValue: _sort,
              onSelected: (sort) => setState(() => _sort = sort),
              itemBuilder: (_) => const [
                PopupMenuItem(value: CollectionSort.recent, child: Text('Recent')),
                PopupMenuItem(value: CollectionSort.title, child: Text('Title')),
                PopupMenuItem(value: CollectionSort.artist, child: Text('Artist')),
                PopupMenuItem(value: CollectionSort.duration, child: Text('Duration')),
              ],
            ),
            IconButton(
              tooltip: 'Select songs',
              icon: const Icon(Icons.checklist_rounded),
              onPressed: songs.isEmpty ? null : () => setState(() => _selectedPaths.add(songs.first.path)),
            ),
          ],
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search songs',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              if (songs.isNotEmpty && !_selecting)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      Text('${widget.songs.length} songs'),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () => _playSongs(songs, shuffle: false),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play All'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Shuffle all',
                        icon: const Icon(Icons.shuffle_rounded),
                        onPressed: () => _playSongs(songs, shuffle: true),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: songs.isEmpty
                    ? Center(child: Text(widget.emptyMessage))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: songs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          final selected = _selectedPaths.contains(song.path);
                          return ListTile(
                            key: ValueKey(song.path),
                            selected: selected,
                            leading: song.artwork == null
                                ? const CircleAvatar(child: Icon(Icons.music_note_rounded))
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(song.artwork!, width: 48, height: 48, fit: BoxFit.cover),
                                  ),
                            title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              '${song.artist.isEmpty ? 'Unknown Artist' : song.artist} • ${formatCollectionDuration(song.duration)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: _selecting
                                ? Checkbox(
                                    value: selected,
                                    onChanged: (_) => _toggleSelection(song.path),
                                  )
                                : PopupMenuButton<String>(
                                    tooltip: 'Song actions',
                                    onSelected: (action) => _songAction(action, song),
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'queue', child: Text('Add to queue')),
                                      PopupMenuItem(value: 'playlist', child: Text('Add to playlist')),
                                      PopupMenuItem(value: 'favorite', child: Text('Toggle favorite')),
                                    ],
                                  ),
                            onLongPress: () => _toggleSelection(song.path),
                            onTap: () => _selecting ? _toggleSelection(song.path) : _playSong(song, songs, index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSelection(String path) {
    setState(() {
      if (!_selectedPaths.add(path)) _selectedPaths.remove(path);
    });
  }

  Future<void> _playSongs(List<CurrentSong> songs, {required bool shuffle}) async {
    if (songs.isEmpty) return;
    final queue = List<CurrentSong>.from(songs);
    if (shuffle) queue.shuffle(Random());
    await _playSong(queue.first, queue, 0);
  }

  Future<void> _playSong(CurrentSong song, List<CurrentSong> queue, int index) async {
    ref.read(queueProvider.notifier).setQueue(queue);
    ref.read(queueIndexProvider.notifier).setIndex(index);
    ref.read(currentSongProvider.notifier).setSong(song);
    await ref.read(audioPlayerProvider).openFile(song.path);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlayerPage()));
  }

  void _addToQueue(List<CurrentSong> songs) {
    if (songs.isEmpty) return;
    ref.read(queueProvider.notifier).setQueue(songs);
    setState(_selectedPaths.clear);
  }

  void _songAction(String action, CurrentSong song) {
    switch (action) {
      case 'queue':
        _addToQueue([song]);
      case 'playlist':
        showCollectionPlaylistPicker(context, ref, [song]);
      case 'favorite':
        ref.read(favoritesProvider.notifier).toggle(song.path);
    }
  }

}

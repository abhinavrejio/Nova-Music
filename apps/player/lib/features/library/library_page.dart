import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/current_song.dart';
import '../../providers/library/library_provider.dart';
import '../../providers/playlists/playlist_provider.dart';
import '../../providers/personalization/library_personalization_provider.dart';
import 'pages/album_detail_page.dart';
import 'pages/artist_detail_page.dart';
import 'pages/folder_detail_page.dart';
import 'pages/genre_detail_page.dart';
import 'pages/liked_songs_page.dart';
import 'pages/library_group_page.dart';
import 'pages/playlist_detail_page.dart';
import 'widgets/library_search_bar.dart';
import 'widgets/library_collections.dart';
import 'widgets/playlist_tile.dart';
import 'widgets/section_header.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  int _albumCount(List<CurrentSong> songs) => _groupByAlbum(songs).length;

  int _artistCount(List<CurrentSong> songs) => _groupByArtist(songs).length;

  int _genreCount(List<CurrentSong> songs) => _groupByGenre(songs).length;

  int _folderCount(List<CurrentSong> songs) => _groupByFolder(songs).length;

  Map<String, List<CurrentSong>> _groupByAlbum(List<CurrentSong> songs) {
    final grouped = <String, List<CurrentSong>>{};

    for (final song in songs) {
      final album = song.album.trim();
      if (album.isEmpty) continue;
      grouped.putIfAbsent(album, () => <CurrentSong>[]).add(song);
    }

    return grouped;
  }

  Map<String, List<CurrentSong>> _groupByArtist(List<CurrentSong> songs) {
    final grouped = <String, List<CurrentSong>>{};

    for (final song in songs) {
      final artist = song.artist.trim();
      if (artist.isEmpty) continue;
      grouped.putIfAbsent(artist, () => <CurrentSong>[]).add(song);
    }

    return grouped;
  }

  Map<String, List<CurrentSong>> _groupByGenre(List<CurrentSong> songs) {
    final grouped = <String, List<CurrentSong>>{};

    for (final song in songs) {
      final genre = song.genre.trim();
      final groupName = genre.isEmpty ? 'Uncategorized' : genre;
      grouped.putIfAbsent(groupName, () => <CurrentSong>[]).add(song);
    }

    return grouped;
  }

  Map<String, List<CurrentSong>> _groupByFolder(List<CurrentSong> songs) {
    final grouped = <String, List<CurrentSong>>{};

    for (final song in songs) {
      final folder = _parentFolder(song.path);
      if (folder.isEmpty) continue;
      grouped.putIfAbsent(folder, () => <CurrentSong>[]).add(song);
    }

    return grouped;
  }

  String _parentFolder(String path) {
    final normalized = path
        .replaceAll('/', Platform.pathSeparator)
        .replaceAll('\\', Platform.pathSeparator);
    final separator = Platform.pathSeparator;
    final index = normalized.lastIndexOf(separator);
    if (index <= 0) return '';
    return normalized.substring(0, index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(libraryProvider);
    final playlists = ref.watch(playlistProvider);
    final visibleSections = ref.watch(libraryPersonalizationProvider);
    final albumCount = _albumCount(songs);
    final artistCount = _artistCount(songs);
    final genreCount = _genreCount(songs);
    final folderCount = _folderCount(songs);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOVA / LIBRARY',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your collection',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${songs.length} songs',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Search
              const LibrarySearchBar(),

              // Collections
              if (visibleSections.contains('Collections')) ...[
                const SectionHeader("Collections"),
                LibraryCollections(songCount: songs.length),
                const SizedBox(height: 20),
              ],

              // Library
              if (visibleSections.any(
                (section) => const {
                  'Songs',
                  'Albums',
                  'Artists',
                  'Genres',
                  'Folders',
                }.contains(section),
              ))
                const SectionHeader("Library"),

              if (visibleSections.contains('Songs'))
                ListTile(
                  leading: const Icon(Icons.music_note),
                  title: const Text("Songs"),
                  subtitle: Text("${songs.length} songs"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LikedSongsPage()),
                    );
                  },
                ),

              if (visibleSections.contains('Albums'))
                ListTile(
                  leading: const Icon(Icons.album),
                  title: const Text("Albums"),
                  subtitle: Text('$albumCount albums'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LibraryGroupPage(
                          title: 'Albums',
                          icon: Icons.album_rounded,
                          groups: _groupByAlbum(songs),
                          onGroupSelected: (name, groupSongs) =>
                              AlbumDetailPage(
                                albumTitle: name,
                                songs: groupSongs,
                              ),
                        ),
                      ),
                    );
                  },
                ),

              if (visibleSections.contains('Artists'))
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Artists"),
                  subtitle: Text('$artistCount artists'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LibraryGroupPage(
                          title: 'Artists',
                          icon: Icons.person_rounded,
                          groups: _groupByArtist(songs),
                          onGroupSelected: (name, groupSongs) =>
                              ArtistDetailPage(
                                artistName: name,
                                songs: groupSongs,
                              ),
                        ),
                      ),
                    );
                  },
                ),

              if (visibleSections.contains('Genres'))
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text("Genres"),
                  subtitle: Text('$genreCount genres'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LibraryGroupPage(
                          title: 'Genres',
                          icon: Icons.category_rounded,
                          groups: _groupByGenre(songs),
                          onGroupSelected: (name, groupSongs) =>
                              GenreDetailPage(
                                genreName: name,
                                songs: groupSongs,
                              ),
                        ),
                      ),
                    );
                  },
                ),

              if (visibleSections.contains('Folders'))
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text("Folders"),
                  subtitle: Text('$folderCount folders'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LibraryGroupPage(
                          title: 'Folders',
                          icon: Icons.folder_rounded,
                          groups: _groupByFolder(songs),
                          onGroupSelected: (name, groupSongs) =>
                              FolderDetailPage(
                                folderPath: name,
                                songs: groupSongs,
                              ),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              if (visibleSections.contains('Playlists'))
                SectionHeader(
                  "Playlists",
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: "Create Playlist",
                    onPressed: () {
                      _showCreatePlaylistDialog(context, ref);
                    },
                  ),
                ),

              if (visibleSections.contains('Playlists') && playlists.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text("No playlists yet.\nTap + to create one."),
                )
              else if (visibleSections.contains('Playlists'))
                ...playlists.map(
                  (playlist) => PlaylistTile(
                    title: playlist.name,
                    songCount: playlist.songCount,
                    isPinned: playlist.isPinned,
                    onPin: () => ref
                        .read(playlistProvider.notifier)
                        .togglePinned(playlist.id),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PlaylistDetailPage(playlist: playlist),
                        ),
                      );
                    },
                    onRename: () =>
                        _showRenamePlaylistDialog(context, ref, playlist),
                    onDelete: () {
                      ref
                          .read(playlistProvider.notifier)
                          .deletePlaylist(playlist.id);
                    },
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenamePlaylistDialog(
    BuildContext context,
    WidgetRef ref,
    dynamic playlist,
  ) {
    final controller = TextEditingController(text: playlist.name);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Rename Playlist'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'New playlist name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  ref
                      .read(playlistProvider.notifier)
                      .renamePlaylist(playlist.id, value);
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Create Playlist"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Playlist name"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isNotEmpty) {
                  ref.read(playlistProvider.notifier).createPlaylist(name);
                }

                Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }
}

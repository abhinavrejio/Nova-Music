import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:player/features/library/library_page.dart';
import 'package:player/features/library/pages/album_detail_page.dart';
import 'package:player/features/library/pages/artist_detail_page.dart';
import 'package:player/features/library/pages/folder_detail_page.dart';
import 'package:player/features/library/pages/genre_detail_page.dart';
import 'package:player/features/library/pages/liked_songs_page.dart';
import 'package:player/features/library/pages/playlist_detail_page.dart';
import 'package:player/models/current_song.dart';
import 'package:player/models/playlist.dart';
import 'package:player/providers/library/library_provider.dart';
import 'package:player/providers/playlists/playlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestLibraryNotifier extends LibraryNotifier {
  TestLibraryNotifier(this.initialSongs);

  final List<CurrentSong> initialSongs;

  @override
  List<CurrentSong> build() => initialSongs;
}

class TestPlaylistNotifier extends PlaylistNotifier {
  TestPlaylistNotifier(this.initialPlaylists);

  final List<Playlist> initialPlaylists;

  @override
  List<Playlist> build() => initialPlaylists;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('Library page shows real album and artist counts from the library data', (tester) async {
    final songs = [
      const CurrentSong(
        path: '/music/after-hours/track-1.mp3',
        title: 'Track 1',
        artist: 'The Weeknd',
        album: 'After Hours',
        genre: 'Synthwave',
        duration: Duration(minutes: 3),
      ),
      const CurrentSong(
        path: '/music/after-hours/track-2.mp3',
        title: 'Track 2',
        artist: 'The Weeknd',
        album: 'After Hours',
        genre: 'Synthwave',
        duration: Duration(minutes: 4),
      ),
      const CurrentSong(
        path: '/music/evolve/track-3.mp3',
        title: 'Track 3',
        artist: 'Imagine Dragons',
        album: 'Evolve',
        genre: 'Rock',
        duration: Duration(minutes: 5),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryProvider.overrideWith(() => TestLibraryNotifier(songs)),
        ],
        child: const MaterialApp(
          home: LibraryPage(),
        ),
      ),
    );

    final pageScrollable = find.byType(Scrollable).last;

    await tester.scrollUntilVisible(find.text('2 albums'), 300, scrollable: pageScrollable);
    expect(find.text('2 albums'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('2 artists'), 300, scrollable: pageScrollable);
    expect(find.text('2 artists'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('2 genres'), 300, scrollable: pageScrollable);
    expect(find.text('2 genres'), findsOneWidget);
  });

  test('Playlist provider renames and deletes playlist entries', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(playlistProvider.notifier);
    await notifier.createPlaylist('Road Trip');

    expect(container.read(playlistProvider), isNotEmpty);

    final created = container.read(playlistProvider).first;
    await notifier.renamePlaylist(created.id, 'Weekend Drive');
    expect(container.read(playlistProvider).first.name, 'Weekend Drive');

    await notifier.deletePlaylist(created.id);
    expect(container.read(playlistProvider), isEmpty);
  });

  testWidgets('Library liked songs card opens the liked songs page', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LibraryPage(),
        ),
      ),
    );

    await tester.tap(find.text('Liked Songs').first);
    await tester.pumpAndSettle();

    expect(find.byType(LikedSongsPage), findsOneWidget);
  });

  testWidgets('Playlist detail page renders the playlist title and songs state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PlaylistDetailPage(
            playlist: Playlist(
              id: 'road-trip',
              name: 'Road Trip',
              songPaths: [],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Road Trip'), findsOneWidget);
    expect(find.text('No songs in this playlist yet.'), findsOneWidget);
  });

  testWidgets('Album detail page renders the album title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AlbumDetailPage(
            albumTitle: 'After Hours',
            songs: [],
          ),
        ),
      ),
    );

    expect(find.text('After Hours'), findsOneWidget);
  });

  testWidgets('Artist detail page renders the artist title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ArtistDetailPage(
            artistName: 'The Weeknd',
            songs: [],
          ),
        ),
      ),
    );

    expect(find.text('The Weeknd'), findsOneWidget);
  });

  testWidgets('Genre detail page renders the genre title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: GenreDetailPage(
            genreName: 'Synthwave',
            songs: [],
          ),
        ),
      ),
    );

    expect(find.text('Synthwave'), findsOneWidget);
  });

  testWidgets('Folder detail page renders the folder path', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: FolderDetailPage(
            folderPath: 'C:/Music',
            songs: [],
          ),
        ),
      ),
    );

    expect(find.text('C:/Music'), findsOneWidget);
  });
}

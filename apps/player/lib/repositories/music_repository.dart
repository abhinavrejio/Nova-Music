import '../models/album.dart';
import '../models/artist.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class MusicRepository {
  const MusicRepository();

  // ----------------------------
  // Songs
  // ----------------------------
  List<Song> getSongs() {
    return const [
      Song(
        id: '1',
        title: 'Blinding Lights',
        artist: 'The Weeknd',
        album: 'After Hours',
        duration: Duration(minutes: 3, seconds: 20),
        artworkUrl: '',
        source: 'mock',
        filePath: '',
      ),
      Song(
        id: '2',
        title: 'Believer',
        artist: 'Imagine Dragons',
        album: 'Evolve',
        duration: Duration(minutes: 3, seconds: 24),
        artworkUrl: '',
        source: 'mock',
        filePath: '',
      ),
      Song(
        id: '3',
        title: 'Starboy',
        artist: 'The Weeknd',
        album: 'Starboy',
        duration: Duration(minutes: 3, seconds: 50),
        artworkUrl: '',
        source: 'mock',
        filePath: '',
      ),
    ];
  }

  // ----------------------------
  // Albums
  // ----------------------------
  List<Album> getAlbums() {
    return const [
      Album(
        id: '1',
        title: 'After Hours',
        artist: 'The Weeknd',
        artworkUrl: '',
      ),
      Album(
        id: '2',
        title: 'Evolve',
        artist: 'Imagine Dragons',
        artworkUrl: '',
      ),
      Album(
        id: '3',
        title: 'Future Nostalgia',
        artist: 'Dua Lipa',
        artworkUrl: '',
      ),
    ];
  }

  // ----------------------------
  // Artists
  // ----------------------------
  List<Artist> getArtists() {
    return const [];
  }

  // ----------------------------
  // Playlists
  // ----------------------------
  List<Playlist> getPlaylists() {
    return const [];
  }
}
import '../models/album.dart';
import '../models/artist.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class MusicRepository {
  const MusicRepository();

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
      ),
      Song(
        id: '2',
        title: 'Believer',
        artist: 'Imagine Dragons',
        album: 'Evolve',
        duration: Duration(minutes: 3, seconds: 24),
        artworkUrl: '',
        source: 'mock',
      ),
    ];
  }

  List<Album> getAlbums() {
    return const [];
  }

  List<Artist> getArtists() {
    return const [];
  }

  List<Playlist> getPlaylists() {
    return const [];
  }
}
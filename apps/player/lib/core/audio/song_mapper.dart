import 'package:on_audio_query/on_audio_query.dart';

import '../../models/song/song.dart';

class SongMapper {
  static Song fromSongModel(SongModel song) {
    return Song(
      id: song.id,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      path: song.data,
      duration: Duration(
        milliseconds: song.duration ?? 0,
      ),
    );
  }
}
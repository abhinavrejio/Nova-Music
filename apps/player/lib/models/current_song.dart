import 'dart:typed_data';

class CurrentSong {
  final String path;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final Uint8List? artwork;

  const CurrentSong({
    required this.path,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.artwork,
  });

  CurrentSong copyWith({
    String? path,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    Uint8List? artwork,
  }) {
    return CurrentSong(
      path: path ?? this.path,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      artwork: artwork ?? this.artwork,
    );
  }
}
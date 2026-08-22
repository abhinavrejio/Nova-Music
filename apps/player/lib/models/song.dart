class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;

  /// Empty until metadata is loaded
  final String artworkUrl;

  /// "mock", "local", "spotify", "apple", etc.
  final String source;

  /// Absolute path to the local file.
  /// Empty for streaming services.
  final String filePath;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.artworkUrl,
    required this.source,
    required this.filePath,
  });

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? artworkUrl,
    String? source,
    String? filePath,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      source: source ?? this.source,
      filePath: filePath ?? this.filePath,
    );
  }
}
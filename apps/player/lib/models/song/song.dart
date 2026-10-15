class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.duration,
  });

  final int id;
  final String title;
  final String artist;
  final String album;
  final String path;
  final Duration duration;
}
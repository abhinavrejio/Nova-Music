class MusicFolder {
  const MusicFolder({
    required this.path,
    required this.songPaths,
  });

  final String path;
  final List<String> songPaths;

  int get songCount => songPaths.length;
}
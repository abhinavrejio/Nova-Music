class Genre {
  const Genre({
    required this.name,
    required this.songPaths,
  });

  final String name;
  final List<String> songPaths;

  int get songCount => songPaths.length;
}
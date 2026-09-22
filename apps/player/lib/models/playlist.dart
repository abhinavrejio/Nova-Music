import 'dart:typed_data';
class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    required this.songPaths,
    this.description = '',
    this.artwork,
    this.isSmartPlaylist = false,
  });

  final String id;
  final String name;
  final List<String> songPaths;
  final String description;
  final Uint8List? artwork;
  final bool isSmartPlaylist;

  int get songCount => songPaths.length;

  Playlist copyWith({
    String? id,
    String? name,
    List<String>? songPaths,
    String? description,
    Uint8List? artwork,
    bool? isSmartPlaylist,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songPaths: songPaths ?? this.songPaths,
      description: description ?? this.description,
      artwork: artwork ?? this.artwork,
      isSmartPlaylist: isSmartPlaylist ?? this.isSmartPlaylist,
    );
  }
}